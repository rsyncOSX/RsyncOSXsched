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

    override init(profile: String?) {
        super.init(profile: profile)
        self.profile = profile
        let schedulesdata = SchedulesData(profile: profile,
                                          validhiddenID: self.configurations?.validhiddenID)
        self.schedules = schedulesdata.schedules
    }
}
