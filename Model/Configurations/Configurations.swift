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

import Cocoa
import Foundation

// Enum which resource to return
enum ResourceInConfiguration {
    case remoteCatalog
    case localCatalog
    case offsiteServer
    case task
}

class Configurations: SetSchedules {
    private var profile: String?
    // The main structure storing all Configurations for tasks
    private var configurations: [Configuration]?
    // valid hiddenIDs
    var validhiddenID: Set<Int>?

    // Function for getting Configurations read into memory
    // - parameter none: none
    // - returns : Array of configurations
    func getConfigurations() -> [Configuration]? {
        return self.configurations
    }

    func gethiddenID(index: Int) -> Int {
        guard index != -1, index < (self.configurations?.count ?? -1) else { return -1 }
        return self.configurations?[index].hiddenID ?? -1
    }

    func setCurrentDateonConfiguration(index: Int, outputprocess: OutputProcess?) {
        guard index > -1 else { return }
        let number = Numbers(outputprocess: outputprocess)
        let hiddenID = self.gethiddenID(index: index)
        let numbers = number.stats()
        self.schedules?.addlogpermanentstore(hiddenID: hiddenID, result: numbers)
        if self.configurations?[index].task == ViewControllerReference.shared.snapshot {
            self.increasesnapshotnum(index: index)
        }
        let currendate = Date()
        self.configurations?[index].dateRun = currendate.en_us_string_from_date()
        // Saving updated configuration in memory to persistent store
        if ViewControllerReference.shared.json {
            PersistentStorageConfigurationJSON(profile: self.profile, writeonly: true).saveconfigInMemoryToPersistentStore()
        } else {
            PersistentStorageConfiguration(profile: self.profile, writeonly: true).saveconfigInMemoryToPersistentStore()
        }
    }

    func getIndex(_ hiddenID: Int) -> Int {
        return self.configurations?.firstIndex(where: { $0.hiddenID == hiddenID }) ?? -1
    }

    private func increasesnapshotnum(index: Int) {
        guard self.configurations != nil else { return }
        let num = self.configurations?[index].snapshotnum ?? 0
        self.configurations?[index].snapshotnum = num + 1
    }

    func getResourceConfiguration(_ hiddenID: Int, resource: ResourceInConfiguration) -> String {
        if let result = self.configurations?.filter({ ($0.hiddenID == hiddenID) }) {
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
        return ""
    }

    // Function for getting all Configurations marked as backup
    // - parameter none: none
    // - returns : Array of NSDictionary
    func getConfigurationsDataSourceSynchronize() -> [NSDictionary]? {
        guard self.configurations != nil else { return nil }
        var configurations = self.configurations?.filter {
            ViewControllerReference.shared.synctasks.contains($0.task)
        }
        var data = [NSDictionary]()
        for i in 0 ..< (configurations?.count ?? 0) {
            if configurations?[i].offsiteServer.isEmpty == true {
                configurations?[i].offsiteServer = "localhost"
            }
            if let config = self.configurations?[i] {
                let row: NSDictionary = ConvertOneConfig(config: config).dict
                data.append(row)
            }
        }
        return data
    }

    init(profile: String?) {
        self.profile = profile
        self.configurations = nil
        // Read and prepare configurations and rsync parameters
        let configurationsdata = ConfigurationsData(profile: profile)
        self.configurations = configurationsdata.configurations
        self.validhiddenID = configurationsdata.validhiddenID
        ViewControllerReference.shared.process = nil
    }
}
