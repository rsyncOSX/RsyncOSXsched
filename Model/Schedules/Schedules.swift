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

class Schedules: ScheduleWriteLoggData {

    var scheduledTasks: NSDictionary?
    var profile: String?

    // Return reference to Schedule data
    // self.Schedule is privat data
    func getSchedule() -> [ConfigurationSchedule] {
        return self.schedules ?? []
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

    init(profile: String?) {
        super.init()
        self.profile = profile
        self.storageapi = PersistentStorageAPI(profile: self.profile)
        self.readschedules()
    }
}
