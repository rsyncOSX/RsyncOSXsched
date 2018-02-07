//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable function_body_length 

import Foundation

final class PersistentStorageConfiguration: Readwritefiles {

    /// Variable holds all configuration data from persisten storage
    private var configurationsAsNSDict: [NSDictionary]?

    /// Function reads configurations from permanent store
    /// - returns : array of NSDictonarys, return might be nil if configuration is already in memory
    func readConfigurationsFromPermanentStore() -> [NSDictionary]? {
        return self.configurationsAsNSDict
    }

    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        var array = [NSDictionary]()
        // Reading Configurations from memory
        let configs: [Configuration] = self.configurations!.getConfigurations()
        for i in 0 ..< configs.count {
            array.append(self.dictionaryFromconfig(index: i))
        }
        // Write array to persistent store
        self.writeToStore(array)
    }

    // Function for returning a NSMutabledictionary from a configuration record
    private func dictionaryFromconfig (index: Int) -> NSMutableDictionary {
        var config: Configuration = self.configurations!.getConfigurations()[index]
        let dict: NSMutableDictionary = [
            "task": config.task,
            "backupID": config.backupID,
            "localCatalog": config.localCatalog,
            "offsiteCatalog": config.offsiteCatalog,
            "batch": config.batch,
            "offsiteServer": config.offsiteServer,
            "offsiteUsername": config.offsiteUsername,
            "parameter1": config.parameter1,
            "parameter2": config.parameter2,
            "parameter3": config.parameter3,
            "parameter4": config.parameter4,
            "parameter5": config.parameter5,
            "parameter6": config.parameter6,
            "dryrun": config.dryrun,
            "dateRun": config.dateRun!,
            "hiddenID": config.hiddenID]
        // All parameters parameter8 - parameter14 are set
        config.parameter8 = self.checkparameter(param: config.parameter8)
        if config.parameter8 != nil {
            dict.setObject(config.parameter8!, forKey: "parameter8" as NSCopying)
        }
        config.parameter9 = self.checkparameter(param: config.parameter9)
        if config.parameter9 != nil {
            dict.setObject(config.parameter9!, forKey: "parameter9" as NSCopying)
        }
        config.parameter10 = self.checkparameter(param: config.parameter10)
        if config.parameter10 != nil {
            dict.setObject(config.parameter10!, forKey: "parameter10" as NSCopying)
        }
        config.parameter11 = self.checkparameter(param: config.parameter11)
        if config.parameter11 != nil {
            dict.setObject(config.parameter11!, forKey: "parameter11" as NSCopying)
        }
        config.parameter12 = self.checkparameter(param: config.parameter12)
        if config.parameter12 != nil {
            dict.setObject(config.parameter12!, forKey: "parameter12" as NSCopying)
        }
        config.parameter13 = self.checkparameter(param: config.parameter13)
        if config.parameter13 != nil {
            dict.setObject(config.parameter13!, forKey: "parameter13" as NSCopying)
        }
        config.parameter14 = self.checkparameter(param: config.parameter14)
        if config.parameter14 != nil {
            dict.setObject(config.parameter14!, forKey: "parameter14" as NSCopying)
        }
        // All Ints are set
        if config.rsyncdaemon != nil {
            dict.setObject(config.rsyncdaemon!, forKey: "rsyncdaemon" as NSCopying)
        }
        if config.sshport != nil {
            dict.setObject(config.sshport!, forKey: "sshport" as NSCopying)
        }
        if config.snapshotnum != nil {
            dict.setObject(config.snapshotnum!, forKey: "snapshotnum" as NSCopying)
        }
        return dict
    }

    private func checkparameter (param: String?) -> String? {
        if let parameter = param {
            guard parameter.isEmpty == false else { return nil }
            return parameter
        } else {
            return nil
        }
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore (_ array: [NSDictionary]) {
        if (self.writeDatatoPersistentStorage(array, task: .configuration)) {
            self.configurationsDelegate?.createandreloadconfigurations()
        }
    }

    init (profile: String?) {
        super.init(task: .configuration, profile: profile)
        self.configurationsAsNSDict = self.getDatafromfile()
    }
}
