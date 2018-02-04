//
//  persistentStoreAPI.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 09/12/15.
//  Copyright © 2015 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorageAPI {

    var profile: String?
    private var configurations: Configurations?
    private var schedules: Schedules?

    // CONFIGURATIONS

    // Read configurations from persisten store
    func getConfigurations() -> [Configuration]? {
        let read = PersistentStorageConfiguration(profile: self.profile, configurations: self.configurations!)
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
        let save = PersistentStorageConfiguration(profile: self.profile, configurations: self.configurations!)
        save.saveconfigInMemoryToPersistentStore()
    }

    // SCHEDULE
    
    // Saving Schedules from memory to persistent store
    func saveScheduleFromMemory() {
        let store = PersistentStorageScheduling(profile: self.profile, schedules: self.schedules, configurations: self.configurations)
        store.savescheduleInMemoryToPersistentStore()
        // Kick off next task
        // self.startnexttask()
    }

    // Read schedules and history
    // If no Schedule from persistent store return nil
    func getScheduleandhistory () -> [ConfigurationSchedule]? {
        let read = PersistentStorageScheduling(profile: self.profile, schedules: self.schedules, configurations: self.configurations)
        var schedule = [ConfigurationSchedule]()
        // Either read from persistent store or
        // return Schedule already in memory
        if read.readSchedulesFromPermanentStore() != nil {
            for dict in read.readSchedulesFromPermanentStore()! {
                if let log = dict.value(forKey: "executed") {
                    let conf = ConfigurationSchedule(dictionary: dict, log: log as? NSArray)
                    schedule.append(conf)
                } else {
                    let conf = ConfigurationSchedule(dictionary: dict, log: nil)
                    schedule.append(conf)
                }
            }
            return schedule
        } else {
            return nil
        }
    }
    
    // USERCONFIG

    func getUserconfiguration (readfromstorage: Bool) -> [NSDictionary]? {
        let store = PersistentStorageUserconfiguration(readfromstorage: readfromstorage, configurations: self.configurations)
        return store.readUserconfigurationsFromPermanentStore()
    }

    init(profile: String?, configurations: Configurations?, schedules: Schedules?) {
        self.profile = profile
        self.configurations = configurations
        self.schedules = schedules
    }
}
