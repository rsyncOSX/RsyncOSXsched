//
//  PersistenStorescheduling.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//   Interface between Schedule in memory and
//   presistent store. Class is a interface
//   for Schedule.
//

import Files
import Foundation

class PersistentStorageScheduling: ReadWriteDictionary, SetSchedules {
    // Variable holds all schedule data from persisten storage
    var schedulesasdictionary: [NSDictionary]?

    // Read schedules and history
    // If no Schedule from persistent store return nil
    func getScheduleandhistory(nolog: Bool) -> [ConfigurationSchedule]? {
        var schedule = [ConfigurationSchedule]()
        guard self.schedulesasdictionary != nil else { return nil }
        for dict in self.schedulesasdictionary! {
            if let log = dict.value(forKey: "executed") {
                let conf = ConfigurationSchedule(dictionary: dict, log: log as? NSArray, nolog: nolog)
                schedule.append(conf)
            } else {
                let conf = ConfigurationSchedule(dictionary: dict, log: nil, nolog: nolog)
                schedule.append(conf)
            }
        }
        return schedule
    }

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        if let dicts: [NSDictionary] = ConvertSchedules(JSON: false).schedules {
            self.writeToStore(array: dicts)
        }
    }

    // Writing schedules to persistent store
    private func writeToStore(array: [NSDictionary]) {
        if self.writeNSDictionaryToPersistentStorage(array: array) {
            self.schedulesDelegate?.createandreloadschedules()
        }
    }

    init(profile: String?, writeonly: Bool) {
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            super.init(whattoreadwrite: .schedule, profile: nil)
        } else {
            super.init(whattoreadwrite: .schedule, profile: profile)
        }
        if writeonly == false {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }
}
