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

import Foundation

final class PersistentStorageScheduling: ReadWriteDictionary, SetSchedules {

    var schedulesasdictionary: [NSDictionary]?

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        var array = [NSDictionary]()
        // Reading Schedules from memory
        if let schedules = self.schedules?.getSchedule() {
            for i in 0 ..< schedules.count {
                let schedule = schedules[i]
                let dict: NSMutableDictionary = [
                    "hiddenID": schedule.hiddenID,
                    "dateStart": schedule.dateStart,
                    "schedule": schedule.schedule,
                    "executed": schedule.logrecords]
                if schedule.dateStop != nil {
                    dict.setValue(schedule.dateStop, forKey: "dateStop")
                }
                if let delete = schedule.delete {
                    if !delete {
                        array.append(dict)
                    }
                } else {
                    array.append(dict)
                }
            }
            // Write array to persistent store
            self.writeToStore(array)
        }
    }

    // Writing schedules to persistent store
    // Schedule is [NSDictionary]
    private func writeToStore (_ array: [NSDictionary]) {
        self.logDelegate?.addlog(logrecord: "Write and reload schedules")
        if self.writeNSDictionaryToPersistentStorage(array) {
            self.schedulesDelegate?.createandreloadschedules()
        }
    }

    init (profile: String?) {
        super.init(whattoreadwrite: .schedule, profile: profile)
        self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}
