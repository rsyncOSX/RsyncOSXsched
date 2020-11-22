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

class PersistentStorageSchedulingPLIST: ReadWriteDictionary, SetSchedules {
    // Variable holds all schedule data from persisten storage
    var schedulesasdictionary: [NSDictionary]?

    // Read schedules and history
    // If no Schedule from persistent store return nil
    func getScheduleandhistory(includelog: Bool) -> [ConfigurationSchedule]? {
        var schedule = [ConfigurationSchedule]()
        guard self.schedulesasdictionary != nil else { return nil }
        for dict in self.schedulesasdictionary! {
            if let log = dict.value(forKey: DictionaryStrings.executed.rawValue) {
                let conf = ConfigurationSchedule(dictionary: dict, log: log as? NSArray, includelog: includelog)
                schedule.append(conf)
            } else {
                let conf = ConfigurationSchedule(dictionary: dict, log: nil, includelog: includelog)
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
    // Schedule is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        self.writeNSDictionaryToPersistentStorage(array: array)
    }

    init(profile: String?, readonly: Bool) {
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            super.init(profile: nil, whattoreadwrite: .schedule)
        } else {
            super.init(profile: profile, whattoreadwrite: .schedule)
        }
        if readonly {
            self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
        }
    }
}
