//
//  PersistentStoreageConfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

class PersistentStorageConfiguration: ReadWriteDictionary, SetConfigurations {
    // Variable holds all configuration data from persisten storage
    var configurationsasdictionary: [NSDictionary]?

    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        var array = [NSDictionary]()
        if let configurations = self.configurations?.getConfigurations() {
            for i in 0 ..< configurations.count {
                if let dict: NSMutableDictionary = ConvertConfigurations(index: i).configuration {
                    array.append(dict)
                }
            }
            self.writeToStore(array: array)
        }
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        self.writeNSDictionaryToPersistentStorage(array: array)
    }

    init(profile: String?) {
        super.init(profile: profile, whattoreadwrite: .configuration)
        if self.configurations == nil {
            self.configurationsasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }

    init(profile: String?, readonly: Bool) {
        super.init(profile: profile, whattoreadwrite: .configuration)
        if readonly == true {
            self.configurationsasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }
}
