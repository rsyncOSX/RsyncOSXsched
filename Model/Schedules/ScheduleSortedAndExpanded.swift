//
//  ScheduleSortedAndExpanded.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ScheduleSortedAndExpand: Setlog {

    // Reference to main View
    private var schedulesNSDictionary: [NSDictionary]?
    private var scheduleConfiguration: [ConfigurationSchedule]?
    private var expandedData = [NSDictionary]()
    var sortedschedules: [NSDictionary]?
    var tcpconnections: TCPconnections?

    // First job to execute. Job is first element in
    func getfirstscheduledtask() -> NSDictionary? {
        guard self.sortedschedules != nil else { return nil}
        guard self.sortedschedules!.count > 0 else {
            ViewControllerReference.shared.scheduledTask = nil
            return nil
        }
        return self.sortedschedules![0]
    }

     // Calculate daily schedules
       private func daily(dateStart: Date, schedule: String, dict: NSDictionary) {
           let cal = Calendar.current
           if let start: Date = cal.date(byAdding: dateStart.dayssincenow, to: dateStart) {
               if start.timeIntervalSinceNow > 0 {
                   let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                   let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                   let time = start.timeIntervalSinceNow
                   let dictSchedule: NSDictionary = [
                       "start": start,
                       "hiddenID": hiddenID,
                       "dateStart": dateStart,
                       "schedule": schedule,
                       "timetostart": time,
                       "profilename": profilename]
                   self.expandedData.append(dictSchedule)
               }
           }
       }

       // Calculate weekly schedules
       private func weekly(dateStart: Date, schedule: String, dict: NSDictionary) {
           let cal = Calendar.current
           if let start: Date = cal.date(byAdding: dateStart.weekssincenowplusoneweek, to: dateStart) {
               if start.timeIntervalSinceNow > 0 {
                   let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                   let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                   let time = start.timeIntervalSinceNow
                   let dictSchedule: NSDictionary = [
                       "start": start,
                       "hiddenID": hiddenID,
                       "dateStart": dateStart,
                       "schedule": schedule,
                       "timetostart": time,
                       "profilename": profilename]
                self.expandedData.append(dictSchedule)
            }
        }
    }

    // Expanding and sorting Scheduledata
    private func sortAndExpandScheduleTasks() {
        guard self.schedulesNSDictionary != nil else { return }
        let dateformatter = Dateandtime().setDateformat()
        for i in 0 ..< self.schedulesNSDictionary!.count {
            let dict = self.schedulesNSDictionary![i]
            let dateStop: Date = dateformatter.date(from: (dict.value(forKey: "dateStop") as? String)!)!
            let dateStart: Date = dateformatter.date(from: (dict.value(forKey: "dateStart") as? String)!)!
            let schedule: String = (dict.value(forKey: "schedule") as? String)!
            let seconds: Double = dateStop.timeIntervalSinceNow
            // Get all jobs which are not executed
            if seconds > 0 {
                switch schedule {
                case "once" :
                    let hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
                    let profilename = dict.value(forKey: "profilename") ?? NSLocalizedString("Default profile", comment: "default profile")
                    let time = seconds
                    let dict: NSDictionary = [
                        "start": dateStart,
                        "hiddenID": hiddenID,
                        "dateStart": dateStart,
                        "schedule": schedule,
                        "timetostart": time,
                        "profilename": profilename]
                    self.expandedData.append(dict)
                case "daily":
                    self.daily(dateStart: dateStart, schedule: schedule, dict: dict)
                case "weekly":
                    self.weekly(dateStart: dateStart, schedule: schedule, dict: dict)
                default:
                    break
                }
            }
            self.sortedschedules = self.expandedData.sorted { (di1, di2) -> Bool in
                if (di1.value(forKey: "start") as? Date)!.timeIntervalSince((di2.value(forKey: "start") as? Date)!)>0 {
                    return false
                } else {
                    return true
                }
            }
        }
    }

    func sortandcountscheduledonetask(hiddenID: Int, profilename: String, dateStart: Date?, number: Bool) -> String {
        var result: [NSDictionary]?
        if dateStart != nil {
            result = self.sortedschedules?.filter({return (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
                && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0 )
                && ($0.value(forKey: "profilename") as? String)! == profilename
                && ($0.value(forKey: "dateStart") as? Date)! == dateStart})
        } else {
            result = self.sortedschedules?.filter({return (($0.value(forKey: "hiddenID") as? Int)! == hiddenID
                && ($0.value(forKey: "start") as? Date)!.timeIntervalSinceNow > 0 )
                && ($0.value(forKey: "profilename") as? String)! == profilename })
        }
        guard result != nil else { return "" }
        let sorted = result!.sorted {(di1, di2) -> Bool in
            if (di1.value(forKey: "start") as? Date)!.timeIntervalSince((di2.value(forKey: "start") as? Date)!)>0 {
                return false
            } else {
                return true
            }
        }
        guard sorted.count > 0 else { return "" }
        if number {
            let firsttask = (sorted[0].value(forKey: "start") as? Date)?.timeIntervalSinceNow
            return Dateandtime().timeString(firsttask!)
        } else {
            let type = sorted[0].value(forKey: "schedule") as? String
            return type ?? ""
        }
    }

    /// Function is reading Schedule plans and transform plans to
    /// array of NSDictionary.
    /// - returns : none
    private func setallscheduledtasksNSDictionary() {
        guard self.scheduleConfiguration != nil else { return }
        var data = [NSDictionary]()
        for i in 0 ..< self.scheduleConfiguration!.count where
            self.scheduleConfiguration![i].dateStop != nil && self.scheduleConfiguration![i].schedule != "stopped" {
                let dict: NSDictionary = [
                    "dateStart": self.scheduleConfiguration![i].dateStart,
                    "dateStop": self.scheduleConfiguration![i].dateStop!,
                    "hiddenID": self.scheduleConfiguration![i].hiddenID,
                    "schedule": self.scheduleConfiguration![i].schedule,
                    "profilename": self.scheduleConfiguration![i].profilename ?? NSLocalizedString("Default profile", comment: "default profile")
                ]
                data.append(dict as NSDictionary)
        }
        self.schedulesNSDictionary = data
    }

    init () {
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Reloading all schedules...", comment: "Sorted"))
        let allschedules = Allschedules()
        self.scheduleConfiguration = allschedules.allschedules
        self.setallscheduledtasksNSDictionary()
        self.sortAndExpandScheduleTasks()
        self.tcpconnections = TCPconnections()
        self.tcpconnections?.testAllremoteserverConnections(offsiteservers: allschedules.alloffsiteservers)
    }
}
