//
//  PersistentStoreageUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorageUserconfiguration: ReadWriteDictionary {
    // Read userconfiguration
    func readuserconfiguration() -> [NSDictionary]? {
        return self.readNSDictionaryFromPersistentStore()
    }

    init() {
        super.init(whattoreadwrite: .userconfig, profile: nil)
    }
}
