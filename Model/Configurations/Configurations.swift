//
//  Configurations.swift
//
//  This object stays in memory runtime and holds key data and operations on Configurations.
//  The obect is the model for the Configurations but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  The object also holds various configurations for RsyncOSX and references to
//  some of the ViewControllers used in calls to delegate functions.
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

// Enum which resource to return
enum ResourceInConfiguration {
    case remoteCatalog
    case localCatalog
    case offsiteServer
    case task
}

class Configurations {

    // Storage API
    var storageapi: PersistentStorageAPI?
    // reference to Process, used for kill in executing task
    var process: Process?
    private var profile: String?
    // The main structure storing all Configurations for tasks
    private var configurations: [Configuration]?
    // Array to store argumenst for all tasks.
    // Initialized during startup
    private var argumentAllConfigurations: [ArgumentsOneConfiguration]?
    // Datasource for NSTableViews
    private var configurationsDataSource: [NSMutableDictionary]?

    /// Function for getting Configurations read into memory
    /// - parameter none: none
    /// - returns : Array of configurations
    func getConfigurations() -> [Configuration] {
        return self.configurations ?? []
    }

    /// Function sets currentDate on Configuration when executed on task
    /// stored in memory and then saves updated configuration from memory to persistent store.
    /// Function also notifies Execute view to refresh data
    /// in tableView.
    /// - parameter index: index of Configuration to update
    func setCurrentDateonConfigurationQuickbackup (_ index: Int, outputprocess: OutputProcess?) {
        if self.configurations![index].task == ViewControllerReference.shared.snapshot {
            self.increasesnapshotnum(index: index)
        }
        let currendate = Date()
        let dateformatter = Dateandtime().setDateformat()
        self.configurations![index].dateRun = dateformatter.string(from: currendate)
        // Saving updated configuration in memory to persistent store
        self.storageapi!.saveConfigFromMemory()
    }

    func getIndex(_ hiddenID: Int) -> Int {
        var index: Int = -1
        loop: for i in 0 ..< self.configurations!.count where self.configurations![i].hiddenID == hiddenID {
            index = i
            break loop
        }
        return index
    }

    private func increasesnapshotnum(index: Int) {
        guard self.configurations != nil else { return }
        let num = self.configurations![index].snapshotnum ?? 0
        self.configurations![index].snapshotnum  = num + 1
    }

    func getResourceConfiguration(_ hiddenID: Int, resource: ResourceInConfiguration) -> String {
        var result = self.configurations!.filter({return ($0.hiddenID == hiddenID)})
        guard result.count > 0 else { return "" }
        switch resource {
        case .localCatalog:
            return result[0].localCatalog
        case .remoteCatalog:
            return result[0].offsiteCatalog
        case .offsiteServer:
            if result[0].offsiteServer.isEmpty {
                return "localhost"
            } else {
                return result[0].offsiteServer
            }
        case .task:
            return result[0].task
        }
    }

    /// Function for getting all Configurations marked as backup
    /// - parameter none: none
    /// - returns : Array of NSDictionary
    func getConfigurationsDataSourcecountBackup() -> [NSMutableDictionary]? {
        let configurations: [Configuration] = self.configurations!.filter({return ($0.task == ViewControllerReference.shared.synchronize ||
            $0.task == ViewControllerReference.shared.snapshot)})
        var data = [NSMutableDictionary]()
        for i in 0 ..< configurations.count {
            let row: NSMutableDictionary = ConvertOneConfig(config: self.configurations![i]).dict
            if (row.value(forKey: "offsiteServerCellID") as? String)?.isEmpty == true {
                row.setValue("localhost", forKey: "offsiteServerCellID")
            }
            data.append(row)
        }
        return data
    }

    private func readconfigurations() {
        self.configurations = [Configuration]()
        self.argumentAllConfigurations = [ArgumentsOneConfiguration]()
        var store: [Configuration]? = self.storageapi!.getConfigurations()
        guard store != nil else { return }
        for i in 0 ..< store!.count {
            if store![i].task == ViewControllerReference.shared.synchronize ||
                store![i].task == ViewControllerReference.shared.snapshot {
                self.configurations!.append(store![i])
                let rsyncArgumentsOneConfig = ArgumentsOneConfiguration(config: store![i])
                self.argumentAllConfigurations!.append(rsyncArgumentsOneConfig)
            }
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var data = [NSMutableDictionary]()
        self.configurationsDataSource = nil
        for i in 0 ..< self.configurations!.count {
            if self.configurations![i].task == ViewControllerReference.shared.synchronize ||
                self.configurations![i].task == ViewControllerReference.shared.snapshot {
                data.append(ConvertOneConfig(config: self.configurations![i]).dict3)
            }
        }
        self.configurationsDataSource = data
    }

    init(profile: String?) {
        self.configurations = nil
        self.argumentAllConfigurations = nil
        self.configurationsDataSource = nil
        self.profile = profile
        self.storageapi = PersistentStorageAPI(profile: self.profile)
        self.readconfigurations()
    }
}
