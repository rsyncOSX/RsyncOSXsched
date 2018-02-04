//
//  This object stays in memory runtime and holds key data and operations on Schedules.
//  The obect is the model for the Schedules but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  Created by Thomas Evensen on 09/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

// Protocol for returning object configurations data
protocol GetSchedulesObject: class {
    func getschedulesobject() -> Schedules?
    func createschedulesobject(profile: String?) -> Schedules?
    func reloadschedulesobject()
}

class Schedules: ScheduleWriteLoggData {

    var scheduledTasks: NSDictionary?
    var profile: String?
    private var configurations: Configurations?

    // Return reference to Schedule data
    // self.Schedule is privat data
    func getSchedule() -> [ConfigurationSchedule] {
        return self.schedules ?? []
    }

    /// Function reads all Schedule data for one task by hiddenID
    /// - parameter hiddenID : hiddenID for task
    /// - returns : array of Schedules sorted after startDate
    func readscheduleonetask (_ hiddenID: Int?) -> [NSMutableDictionary]? {
        guard hiddenID != nil else { return nil }
        var row: NSMutableDictionary
        var data = [NSMutableDictionary]()
        for i in 0 ..< self.schedules!.count {
            if self.schedules![i].hiddenID == hiddenID {
                row = [
                    "dateStart": self.schedules![i].dateStart,
                    "stopCellID": 0,
                    "deleteCellID": 0,
                    "dateStop": "",
                    "schedule": self.schedules![i].schedule,
                    "hiddenID": schedules![i].hiddenID,
                    "numberoflogs": String(schedules![i].logrecords.count)
                ]
                if self.schedules![i].dateStop == nil {
                    row.setValue("no stop date", forKey: "dateStop")
                } else {
                    row.setValue(self.schedules![i].dateStop, forKey: "dateStop")
                }
                if self.schedules![i].schedule == "stopped" {
                    row.setValue(1, forKey: "stopCellID")
                }
                data.append(row)
            }
            // Sorting schedule after dateStart, last startdate on top
            data.sort { (sched1, sched2) -> Bool in
                let dateformatter = Tools(configurations: self.configurations!).setDateformat()
                if dateformatter.date(from: (sched1.value(forKey: "dateStart") as? String)!)! >
                    dateformatter.date(from: (sched2.value(forKey: "dateStart") as? String)!)! {
                    return true
                } else {
                    return false
                }
            }
        }
        return data
    }


    // Check if hiddenID is in Scheduled tasks
    func hiddenIDinSchedule(_ hiddenID: Int) -> Bool {
        let result = self.schedules!.filter({return ($0.hiddenID == hiddenID && $0.dateStop != nil)})
        if result.isEmpty {
            return false
        } else {
            return true
        }
    }

    // Returning the set of executed tasks for å schedule.
    // Used for recalcutlate the parent key when task change schedule
    // from active to "stopped"
    private func getScheduleExecuted(_ hiddenID: Int) -> [NSMutableDictionary]? {
        var result = self.schedules!.filter({return ($0.hiddenID == hiddenID) && ($0.schedule == "stopped")})
        if result.count > 0 {
            let schedule = result.removeFirst()
            return schedule.logrecords
        } else {
            return nil
        }
    }

    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    private func readschedules() {
        var store: [ConfigurationSchedule]? = self.storageapi!.getScheduleandhistory()
        guard store != nil else { return }
        var data = [ConfigurationSchedule]()
        for i in 0 ..< store!.count {
            data.append(store![i])
        }
        // Sorting schedule after hiddenID
        data.sort { (schedule1, schedule2) -> Bool in
            if schedule1.hiddenID > schedule2.hiddenID {
                return false
            } else {
                return true
            }
        }
        // Setting self.Schedule as data
        self.schedules = data
    }

    init(profile: String?, configuration: Configurations?) {
        self.configurations = configuration
        super.init(configurations: configuration)
        self.profile = profile
        self.storageapi = PersistentStorageAPI(profile: self.profile, configurations: configuration, schedules: self)
        self.readschedules()
    }
}
