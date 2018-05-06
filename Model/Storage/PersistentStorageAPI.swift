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
        // Either read from persistent store or
        // return Configurations already in memory
        if read.readConfigurationsFromPermanentStore() != nil {
            var Configurations = [Configuration]()
            for dict in read.readConfigurationsFromPermanentStore()! {
                let conf = Configuration(dictionary: dict)
                Configurations.append(conf)
            }
            return Configurations
        } else {
            return nil
        }
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

    // Read schedules and history
    // If no Schedule from persistent store return nil
    func getScheduleandhistory(nolog: Bool) -> [ConfigurationSchedule]? {
        let read = PersistentStorageScheduling(profile: self.profile)
        var schedule = [ConfigurationSchedule]()
        // Either read from persistent store or
        // return Schedule already in memory
        if read.readSchedulesFromPermanentStore() != nil {
            for dict in read.readSchedulesFromPermanentStore()! {
                dict.setValue(self.profile, forKey: "profilename")
                if let log = dict.value(forKey: "executed") {
                    let scheduleconfig = ConfigurationSchedule(dictionary: dict, log: log as? NSArray, nolog: nolog)
                    schedule.append(scheduleconfig)
                } else {
                    let scheduleconfig = ConfigurationSchedule(dictionary: dict, log: nil, nolog: nolog)
                    schedule.append(scheduleconfig)
                }
            }
            return schedule
        } else {
            return nil
        }
    }

    // USERCONFIG

    func getUserconfiguration (readfromstorage: Bool) -> [NSDictionary]? {
        let store = PersistentStorageUserconfiguration(readfromstorage: readfromstorage)
        return store.readUserconfigurationsFromPermanentStore()
    }

    init(profile: String?) {
        self.profile = profile
    }
}
