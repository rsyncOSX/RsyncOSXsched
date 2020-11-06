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
                var inserted: Bool = self.addlogexisting(hiddenID: hiddenID, result: resultannotaded ?? "", date: date)
                // Record does not exist, create new Schedule (not inserted)
                if inserted == false {
                    inserted = self.addlognew(hiddenID: hiddenID, result: resultannotaded ?? "", date: date)
                }
                if inserted {
                    if ViewControllerReference.shared.json {
                        PersistentStorageSchedulingJSON(profile: self.profile).savescheduleInMemoryToPersistentStore()
                    } else {
                        PersistentStorageScheduling(profile: self.profile).savescheduleInMemoryToPersistentStore()
                    }
                    self.deselectrowtable(vcontroller: .vctabmain)
                }
            }
        }
    }

    func addlogexisting(hiddenID: Int, result: String, date: String) -> Bool {
        if ViewControllerReference.shared.synctasks.contains(self.configurations?.getResourceConfiguration(hiddenID, resource: .task) ?? "") {
            if let index = self.schedules?.firstIndex(where: { $0.hiddenID == hiddenID
                    && $0.schedule == Scheduletype.manuel.rawValue
                    && $0.dateStart == "01 Jan 1900 00:00"
            }) {
                var log = Log()
                log.dateExecuted = date
                log.resultExecuted = result
                self.schedules?[index].logrecords?.append(log)
                return true
            }
        }
        return false
    }

    func addlognew(hiddenID: Int, result: String, date: String) -> Bool {
        if ViewControllerReference.shared.synctasks.contains(self.configurations?.getResourceConfiguration(hiddenID, resource: .task) ?? "") {
            let masterdict = NSMutableDictionary()
            masterdict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
            masterdict.setObject("01 Jan 1900 00:00", forKey: "dateStart" as NSCopying)
            masterdict.setObject(Scheduletype.manuel.rawValue, forKey: "schedule" as NSCopying)
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

    func getconfig(hiddenID: Int) -> Configuration? {
        let index = self.configurations?.getIndex(hiddenID) ?? 0
        return self.configurations?.getConfigurations()[index]
    }

    init(profile: String?) {
        self.profile = profile
        self.schedules = [ConfigurationSchedule]()
    }
}
