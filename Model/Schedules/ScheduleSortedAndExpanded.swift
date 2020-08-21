//
//  ScheduleSortedAndExpanded.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length trailing_comma

import Cocoa
import Foundation

class ScheduleSortedAndExpand: Setlog {
    // Reference to main View
    private var schedulesNSDictionary: [NSDictionary]?
    private var scheduleConfiguration: [ConfigurationSchedule]?
    private var expandedData: [NSDictionary]?
    var sortedschedules: [NSDictionary]?
    var delta: [String]?
    var tcpconnections: TCPconnections?

    // First job to execute. Job is first element in
    func getfirstscheduledtask() -> NSDictionary? {
        guard (self.sortedschedules?.count ?? 0) > 0 else {
            ViewControllerReference.shared.scheduledTask = nil
            return nil
        }
        return self.sortedschedules?[0]
    }

    func getsecondscheduledtask() -> NSDictionary? {
        guard (self.sortedschedules?.count ?? 0) > 1 else { return nil }
        return self.sortedschedules?[1]
    }

    // Calculate daily schedules
    private func daily(dateStart: Date, schedule: String, dict: NSDictionary) {
        let calendar = Calendar.current
        var days: Int?
        if dateStart.daystonow == Date().daystonow, dateStart > Date() {
            days = dateStart.daystonow
        } else {
            days = dateStart.daystonow + 1
        }
        let components = DateComponents(day: days)
        if let start: Date = calendar.date(byAdding: components, to: dateStart) {
            if start.timeIntervalSinceNow > 0 {
                if let hiddenID = (dict.value(forKey: "hiddenID") as? Int) {
                    let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                    let time = start.timeIntervalSinceNow
                    let dictschedule: NSDictionary = [
                        "start": start,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule,
                        "timetostart": time,
                        "profilename": profilename,
                    ]
                    self.expandedData?.append(dictschedule)
                }
            }
        }
    }

    // Calculate weekly schedules
    private func weekly(dateStart: Date, schedule: String, dict: NSDictionary) {
        let calendar = Calendar.current
        var weekofyear: Int?
        if dateStart.weekstonow == Date().weekstonow, dateStart > Date() {
            weekofyear = dateStart.weekstonow
        } else {
            weekofyear = dateStart.weekstonow + 1
        }
        let components = DateComponents(weekOfYear: weekofyear)
        if let start: Date = calendar.date(byAdding: components, to: dateStart) {
            if start.timeIntervalSinceNow > 0 {
                if let hiddenID = (dict.value(forKey: "hiddenID") as? Int) {
                    let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                    let time = start.timeIntervalSinceNow
                    let dictschedule: NSDictionary = [
                        "start": start,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule,
                        "timetostart": time,
                        "profilename": profilename,
                    ]
                    self.expandedData?.append(dictschedule)
                }
            }
        }
    }

    // Expanding and sorting Scheduledata
    private func sortAndExpandScheduleTasks() {
        for i in 0 ..< (self.schedulesNSDictionary?.count ?? 0) {
            let dict = self.schedulesNSDictionary![i]
            let dateStop: Date = (dict.value(forKey: "dateStop") as? String)?.en_us_date_from_string() ?? Date()
            let dateStart: Date = (dict.value(forKey: "dateStart") as? String)?.en_us_date_from_string() ?? Date()
            let schedule: String = (dict.value(forKey: "schedule") as? String) ?? Scheduletype.once.rawValue
            let seconds: Double = dateStop.timeIntervalSinceNow
            // Get all jobs which are not executed
            if seconds > 0 {
                switch schedule {
                case Scheduletype.once.rawValue:
                    if let hiddenID = (dict.value(forKey: "hiddenID") as? Int) {
                        let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                        let time = seconds
                        let dictschedule: NSDictionary = [
                            "start": dateStart,
                            "hiddenID": hiddenID,
                            "dateStart": dateStart,
                            "schedule": schedule,
                            "timetostart": time,
                            "profilename": profilename,
                        ]
                        self.expandedData?.append(dictschedule)
                    }
                case Scheduletype.daily.rawValue:
                    self.daily(dateStart: dateStart, schedule: schedule, dict: dict)
                case Scheduletype.weekly.rawValue:
                    self.weekly(dateStart: dateStart, schedule: schedule, dict: dict)
                default:
                    break
                }
            }
            self.sortedschedules = self.expandedData?.sorted { (date1, date2) -> Bool in
                if let date1 = date1.value(forKey: "start") as? Date {
                    if let date2 = date2.value(forKey: "start") as? Date {
                        if date1.timeIntervalSince(date2) > 0 {
                            return false
                        } else {
                            return true
                        }
                    }
                }
                return false
            }
        }
        self.adddelta()
    }

    func adddelta() {
        // calculate delta time
        guard (self.sortedschedules?.count ?? 0) > 1 else { return }
        self.delta = [String]()
        self.delta?.append("0")
        let timestring = Dateandtime()
        for i in 1 ..< (self.sortedschedules?.count ?? 0) {
            if let t1 = self.sortedschedules?[i - 1].value(forKey: "timetostart") as? Double {
                if let t2 = self.sortedschedules?[i].value(forKey: "timetostart") as? Double {
                    self.delta?.append(timestring.timestring(seconds: t2 - t1))
                }
            }
        }
    }

    func sortandcountscheduledonetask(_ hiddenID: Int, profilename: String?, number: Bool) -> String {
        var result: [NSDictionary]?
        if profilename != nil {
            result = self.sortedschedules?.filter { (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
                    && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0)
                && ($0.value(forKey: "profilename") as? String)! == profilename!
            }
        } else {
            result = self.sortedschedules?.filter { (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
                    && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0) }
        }
        guard result != nil else { return "" }
        let sorted = result!.sorted { (di1, di2) -> Bool in
            if (di1.value(forKey: "start") as? Date)!.timeIntervalSince((di2.value(forKey: "start") as? Date)!) > 0 {
                return false
            } else {
                return true
            }
        }
        guard sorted.count > 0 else { return "" }
        if number {
            if let firsttask = (sorted[0].value(forKey: "start") as? Date)?.timeIntervalSinceNow {
                return Dateandtime().timestring(seconds: firsttask)
            } else {
                return ""
            }
        } else {
            let type = sorted[0].value(forKey: "schedule") as? String
            return type ?? ""
        }
    }

    // Function is reading Schedule plans and transform plans to array of NSDictionary.
    private func setallscheduledtasksNSDictionary() {
        var data = [NSDictionary]()
        for i in 0 ..< (self.scheduleConfiguration?.count ?? 0) where
            self.scheduleConfiguration?[i].dateStop != nil && self.scheduleConfiguration?[i].schedule != "stopped"
        {
            let dict: NSDictionary = [
                "dateStart": self.scheduleConfiguration?[i].dateStart ?? "",
                "dateStop": self.scheduleConfiguration?[i].dateStop ?? "",
                "hiddenID": self.scheduleConfiguration?[i].hiddenID ?? -1,
                "schedule": self.scheduleConfiguration?[i].schedule ?? "",
                "profilename": self.scheduleConfiguration?[i].profilename ?? NSLocalizedString("Default profile", comment: "default profile"),
            ]
            data.append(dict as NSDictionary)
        }
        self.schedulesNSDictionary = data
    }

    init() {
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Reloading all schedules...", comment: "Sorted"))
        self.expandedData = [NSDictionary]()
        let allschedules = Allschedules()
        self.scheduleConfiguration = allschedules.allschedules
        self.setallscheduledtasksNSDictionary()
        self.sortAndExpandScheduleTasks()
        self.tcpconnections = TCPconnections()
        self.tcpconnections?.testAllremoteserverConnections(offsiteservers: allschedules.alloffsiteservers)
    }
}
