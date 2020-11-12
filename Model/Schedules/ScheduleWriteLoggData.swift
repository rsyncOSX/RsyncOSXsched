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
                if let dict = ViewControllerReference.shared.scheduledTask {
                    let schedule = dict.value(forKey: DictionaryStrings.schedule.rawValue) as? String ?? ""
                    let dateStart = (dict.value(forKey: DictionaryStrings.dateStart.rawValue) as? Date)?.en_us_string_from_date() ?? ""
                    var inserted: Bool = self.addlogexisting(hiddenID: hiddenID, result: resultannotaded ?? "",
                                                             date: date,
                                                             schedule: schedule,
                                                             dateStart: dateStart)
                    if inserted == false {
                        inserted = self.addlognew(hiddenID: hiddenID, result: resultannotaded ?? "",
                                                  date: date,
                                                  schedule: schedule,
                                                  dateStart: dateStart)
                    }
                    if inserted {
                        if ViewControllerReference.shared.json == true {
                            PersistentStorageSchedulingJSON(profile: self.profile, writeonly: true).savescheduleInMemoryToPersistentStore()
                        } else {
                            PersistentStorageScheduling(profile: self.profile, writeonly: true).savescheduleInMemoryToPersistentStore()
                        }
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
                if self.schedules?[index].logrecords == nil {
                    self.schedules?[index].logrecords = [Log]()
                }
                var log = Log()
                log.dateExecuted = date
                log.resultExecuted = result
                self.schedules?[index].logrecords?.append(log)
                return true
            }
        }
        return false
    }

    func addlognew(hiddenID: Int, result: String, date: String, schedule _: String, dateStart _: String) -> Bool {
        if ViewControllerReference.shared.synctasks.contains(self.configurations?.getResourceConfiguration(hiddenID, resource: .task) ?? "") {
            let main = NSMutableDictionary()
            main.setObject(hiddenID, forKey: DictionaryStrings.hiddenID.rawValue as NSCopying)
            main.setObject("01 Jan 1900 00:00", forKey: DictionaryStrings.dateStart.rawValue as NSCopying)
            main.setObject(Scheduletype.manuel.rawValue, forKey: DictionaryStrings.schedule.rawValue as NSCopying)
            let dict = NSMutableDictionary()
            dict.setObject(date, forKey: DictionaryStrings.dateExecuted.rawValue as NSCopying)
            dict.setObject(result, forKey: DictionaryStrings.resultExecuted.rawValue as NSCopying)
            let executed = NSMutableArray()
            executed.add(dict)
            let newSchedule = ConfigurationSchedule(dictionary: main, log: executed, nolog: false)
            self.schedules?.append(newSchedule)
            return true
        }
        return false
    }

    private func getconfig(hiddenID: Int) -> Configuration? {
        if let index = self.configurations?.getIndex(hiddenID) {
            guard index > -1 else { return nil }
            return self.configurations?.getConfigurations()?[index]
        }
        return nil
    }

    init(profile: String?) {
        self.profile = profile
        self.schedules = [ConfigurationSchedule]()
    }
}
