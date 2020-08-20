//
//  ScheduleWriteLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 19.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ScheduleWriteLoggData: SetConfigurations {
    var schedules: [ConfigurationSchedule]?
    var profile: String?

    typealias Row = (Int, Int)

    // Function adds results of task to file (via memory). Memory are
    // saved after changed. Used in single tasks
    func addlogpermanentstore(hiddenID: Int, result: String) {
        if ViewControllerReference.shared.detailedlogging {
            // Set the current date
            let currendate = Date()
            let date = currendate.en_us_string_from_date()
            if let config = self.getconfig(hiddenID: hiddenID) {
                var resultannotaded: String?
                if config.task == ViewControllerReference.shared.snapshot {
                    let snapshotnum = String(config.snapshotnum!)
                    resultannotaded = "(" + snapshotnum + ") " + result
                } else {
                    resultannotaded = result
                }
                if let dict = ViewControllerReference.shared.scheduledTask {
                    let schedule = dict.value(forKey: "schedule") as? String ?? ""
                    let dateStart = dict.value(forKey: "dateStart") as? String ?? ""
                    var inserted: Bool = self.addlogexisting(hiddenID: hiddenID, result: resultannotaded ?? "", date: date, schedule: schedule, dateStart: dateStart)
                    // Record does not exist, create new Schedule (not inserted)
                    if inserted == false {
                        inserted = self.addlognew(hiddenID: hiddenID, result: resultannotaded ?? "", date: date, schedule: schedule, dateStart: dateStart)
                    }
                    if inserted {
                        PersistentStorageScheduling(profile: self.profile).savescheduleInMemoryToPersistentStore()
                    }
                }
            }
        }
    }

    func addlogexisting(hiddenID: Int, result: String, date: String, schedule: String, dateStart: String) -> Bool {
        if ViewControllerReference.shared.synctasks.contains(self.configurations?.getResourceConfiguration(hiddenID, resource: .task) ?? "") {
            if let index = self.schedules?.firstIndex(where: { $0.hiddenID == hiddenID
                    && $0.schedule == schedule
                    && $0.dateStart == dateStart
            }) {
                let dict = NSMutableDictionary()
                dict.setObject(date, forKey: "dateExecuted" as NSCopying)
                dict.setObject(result, forKey: "resultExecuted" as NSCopying)
                self.schedules?[index].logrecords.append(dict)
                return true
            }
        }
        return false
    }

    private func addlognew(hiddenID: Int, result: String, date: String, schedule: String, dateStart: String) -> Bool {
        if ViewControllerReference.shared.synctasks.contains(self.configurations?.getResourceConfiguration(hiddenID, resource: .task) ?? "") {
            let masterdict = NSMutableDictionary()
            masterdict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
            masterdict.setObject(dateStart, forKey: "dateStart" as NSCopying)
            masterdict.setObject(schedule, forKey: "schedule" as NSCopying)
            let dict = NSMutableDictionary()
            dict.setObject(date, forKey: "dateExecuted" as NSCopying)
            dict.setObject(result, forKey: "resultExecuted" as NSCopying)
            let executed = NSMutableArray()
            executed.add(dict)
            let newSchedule = ConfigurationSchedule(dictionary: masterdict, log: executed, nolog: false)
            self.schedules?.append(newSchedule)
            return true
        }
        return false
    }

    private func getconfig(hiddenID: Int) -> Configuration? {
        let index = self.configurations?.getIndex(hiddenID) ?? 0
        return self.configurations?.getConfigurations()[index]
    }

    init(profile: String?) {
        self.profile = profile
        self.schedules = [ConfigurationSchedule]()
    }
}
