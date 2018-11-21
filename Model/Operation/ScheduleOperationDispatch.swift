//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class ScheduleOperationDispatch: SetSchedules, SecondsBeforeStart, Setlog {

    private var workitem: DispatchWorkItem?

    private func dispatchtask(_ seconds: Int) {
        let scheduledtask = DispatchWorkItem { [weak self] in
            _ = ExecuteScheduledTask()
        }
        self.workitem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }

    init() {
        weak var updatestatuslightDelegate: Updatestatuslight?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        let seconds = self.secondsbeforestart()
        guard seconds > 0 else {
            self.logDelegate?.addlog(logrecord: "Schedule dispatch: no more scheduled task in queue")
            updatestatuslightDelegate?.updatestatuslight(color: .red)
            return
        }
        let timestring = Dateandtime().timeString(seconds)
        self.logDelegate?.addlog(logrecord: "Schedule dispatch: setting next scheduled task in: " + timestring)
        self.dispatchtask(Int(seconds))
        // Set reference to schedule for later cancel if any
        ViewControllerReference.shared.dispatchTaskWaiting = self.workitem
        updatestatuslightDelegate?.updatestatuslight(color: .green)
    }
}
