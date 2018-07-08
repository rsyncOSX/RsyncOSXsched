//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class ScheduleOperationDispatch: SetSchedules, SecondsBeforeStart, Setlog {

    private var pendingRequestWorkItem: DispatchWorkItem?

    private func dispatchtaskmocup(_ seconds: Int) {
        let scheduledtask = DispatchWorkItem { [weak self] in
            weak var reloadDelegate: Reloadsortedandrefresh?
            reloadDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
            reloadDelegate?.reloadsortedandrefreshtabledata()
        }
        self.pendingRequestWorkItem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }
    
    private func dispatchtask(_ seconds: Int) {
        let scheduledtask = DispatchWorkItem { [weak self] in
            _ = ExecuteTaskDispatch()
        }
        self.pendingRequestWorkItem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }

    init() {
        weak var updatestatuslightDelegate: Updatestatuslight?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        let seconds = self.secondsbeforestart()
        guard ViewControllerReference.shared.executeschedulesmocup == false else {
            guard seconds > 0 else {
                self.logDelegate?.addlog(logrecord: "Mocup timer: no more scheduled task in queue")
                updatestatuslightDelegate?.updatestatuslight(color: .red)
                return
            }
            updatestatuslightDelegate?.updatestatuslight(color: .yellow)
            self.logDelegate?.addlog(logrecord: "Mocup timer: task starts in: " + String(Int(seconds)))
            self.dispatchtaskmocup(Int(seconds))
            return
        }
        guard seconds > 0 else {
            self.logDelegate?.addlog(logrecord: "Timer: no more scheduled task in queue")
            updatestatuslightDelegate?.updatestatuslight(color: .red)
            return
        }
        let timestring = Tools().timeString(seconds)
        self.logDelegate?.addlog(logrecord: "Timer: setting next scheduled task in: " + timestring)
        self.dispatchtask(Int(seconds))
        // Set reference to schedule for later cancel if any
        ViewControllerReference.shared.dispatchTaskWaiting = self.pendingRequestWorkItem
        updatestatuslightDelegate?.updatestatuslight(color: .green)
    }
}
