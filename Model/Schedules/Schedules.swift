//
//  This object stays in memory runtime and holds key data and operations on Schedules.
//  The obect is the model for the Schedules but also acts as Controller when
//  the ViewControllers reads or updates data.
//
//  Created by Thomas Evensen on 09/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

enum Scheduletype: String {
    case once
    case daily
    case weekly
    case manuel
    case stopped
}

class Schedules: ScheduleWriteLoggData {
    // Return reference to Schedule data
    // self.Schedule is privat data
    func getSchedule() -> [ConfigurationSchedule] {
        return self.schedules ?? []
    }

    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    func readschedulesplist() {
        var store = PersistentStorageScheduling(profile: self.profile, writeonly: false).getScheduleandhistory(nolog: false)
        guard store != nil else { return }
        var data = [ConfigurationSchedule]()
        for i in 0 ..< (store?.count ?? 0) where store?[i].logrecords?.isEmpty == false || store?[i].dateStop != nil {
            store?[i].profilename = self.profile
            if let store = store?[i] {
                data.append(store)
            }
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

    // Function for reading all jobs for schedule and all history of past executions.
    // Schedules are stored in self.schedules. Schedules are sorted after hiddenID.
    func readschedulesjson() {
        let store = PersistentStorageSchedulingJSON(profile: self.profile, writeonly: false).decodedjson
        var data = [ConfigurationSchedule]()
        let transform = TransformSchedulefromJSON()
        for i in 0 ..< (store?.count ?? 0) {
            if let scheduleitem = (store?[i] as? DecodeScheduleJSON) {
                var transformed = transform.transform(object: scheduleitem)
                transformed.profilename = self.profile
                data.append(transformed)
            }
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

    override init(profile: String?) {
        super.init(profile: profile)
        self.profile = profile
        if ViewControllerReference.shared.json {
            self.readschedulesjson()
        } else {
            self.readschedulesplist()
        }
    }
}
