//
//  persistentStoreAPI.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorageAPI: SetConfigurations, SetSchedules {

    var profile: String?

    // CONFIGURATIONS
    // Read configurations from persisten store
    func getConfigurations() -> [Configuration]? {
        let read = PersistentStorageConfiguration(profile: self.profile)
        guard read.configurationsasdictionary != nil else { return nil}
        var Configurations = [Configuration]()
        for dict in read.configurationsasdictionary! {
            let conf = Configuration(dictionary: dict)
            Configurations.append(conf)
        }
        return Configurations
    }

    // Saving configuration from memory to persistent store
    func saveConfigFromMemory() {
        let save = PersistentStorageConfiguration(profile: self.profile)
        save.saveconfigInMemoryToPersistentStore()
    }

    // SCHEDULE

    // Saving Schedules from memory to persistent store
    func saveScheduleFromMemory() {
        let store = PersistentStorageScheduling(profile: self.profile)
        store.savescheduleInMemoryToPersistentStore()
    }

    init(profile: String?) {
        self.profile = profile
    }
}
