//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable function_body_length cyclomatic_complexity

import Foundation

final class PersistentStorageConfiguration: ReadWriteDictionary {

    /// Variable holds all configuration data from persisten storage
    var configurationsasdictionary: [NSDictionary]?

    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        var array = [NSDictionary]()
        let configs: [Configuration] = self.configurations!.getConfigurations()
        for i in 0 ..< configs.count {
            let dict: NSMutableDictionary = ConvertConfigurations().convertconfiguration(index: i)
            array.append(dict)
        }
        self.writeToStore(array: array)
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore (array: [NSDictionary]) {
        self.logDelegate?.addlog(logrecord: "Write and reload configurations")
        if self.writeNSDictionaryToPersistentStorage(array) {
            self.configurationsDelegate?.createandreloadconfigurations()
        }
    }

    init (profile: String?) {
        super.init(whattoreadwrite: .configuration, profile: profile)
        self.configurationsasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}
