//
//  PersistentStoreageUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//  

import Foundation

final class PersistentStorageUserconfiguration: Readwritefiles {

    /// Variable holds all configuration data
    private var userconfiguration: [NSDictionary]?

    /// Function reads configurations from permanent store
    /// - returns : array of NSDictonarys, return might be nil
    func readUserconfigurationsFromPermanentStore() -> [NSDictionary]? {
        return self.userconfiguration
    }

    init (readfromstorage: Bool) {
        super.init(task: .userconfig, profile: nil)
        if readfromstorage {
            self.userconfiguration = self.getDatafromfile()
        }
    }
}
