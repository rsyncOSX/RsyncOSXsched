//
//  Loaddataonstart.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 04/08/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

class Loaddataonstart {
    var configurations: Configurations?
    var schedules: Schedules?
    var schedulesortedandexpanded: ScheduleSortedAndExpand?

    private func startfirstscheduledtask() {
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        ViewControllerReference.shared.timerTaskWaiting?.invalidate()
        ViewControllerReference.shared.dispatchTaskWaiting = nil
        ViewControllerReference.shared.timerTaskWaiting = nil
        ViewControllerReference.shared.scheduledTask = self.schedulesortedandexpanded?.getfirstscheduledtask()
        _ = ScheduleOperationDispatch()
        // We use Dispatch not Timer
        // _ = ScheduleOperationTimer()
    }

    init() {
        if let userconfiguration = PersistentStorageUserconfiguration().readuserconfiguration() {
            _ = Userconfiguration(userconfigRsyncOSX: userconfiguration)
        }
        self.configurations = Configurations(profile: nil)
        self.schedules = Schedules(profile: nil)
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstscheduledtask()
        ViewControllerReference.shared.loaddataonstart = self
    }
}
