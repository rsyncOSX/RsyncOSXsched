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
// swiftlint:disable line_length

import Foundation

final class PersistentStorageScheduling: ReadWriteDictionary, SetSchedules {
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
        if let dicts: [NSDictionary] = ConvertSchedules().schedules {
            self.writeToStore(array: dicts)
        }
    }

    // Writing schedules to persistent store
    // Schedule is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Write and reload schedules", comment: "Storage"))
        if self.writeNSDictionaryToPersistentStorage(array) {
            self.schedulesDelegate?.createandreloadschedules()
        }
    }

    init(profile: String?) {
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            super.init(whattoreadwrite: .schedule, profile: nil, configpath: ViewControllerReference.shared.configpath)
        } else {
            super.init(whattoreadwrite: .schedule, profile: profile, configpath: ViewControllerReference.shared.configpath)
        }
        self.schedulesasdictionary = self.readNSDictionaryFromPersistentStore()
    }
}
