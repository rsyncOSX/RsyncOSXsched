//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

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
            if let dict: NSMutableDictionary = ConvertConfigurations(index: i).configuration {
                 array.append(dict)
            }
        }
        self.writeToStore(array: array)
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore (array: [NSDictionary]) {
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Write and reload configurations", comment: "Storage"))
        if self.writeNSDictionaryToPersistentStorage(array) {
            self.configurationsDelegate?.createandreloadconfigurations()
        }
    }

    init (profile: String?) {
        super.init(whattoreadwrite: .configuration, profile: profile)
        self.configurationsasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}
