//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class ScheduleOperationDispatch: SecondsBeforeStart, SetSortedAndExpanded, Setlog {

    private var pendingRequestWorkItem: DispatchWorkItem?
    
    private func dispatchtasktest(_ seconds: Int) {
        self.logDelegate?.addlog(logrecord: "Mocup dispatch: task starts in: " + String(Int(seconds)))
        let scheduledtask = DispatchWorkItem { [weak self] in
            weak var reloadDelegate: Reloadsortedandrefresh?
            reloadDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
            reloadDelegate?.reloadsortedandrefreshtabledata()
        }
        self.pendingRequestWorkItem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }

    private func dispatchtask(_ seconds: Int) {
        self.logDelegate?.addlog(logrecord: "Dispatch: next task in seconds: " + String(Int(seconds)))
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
                self.logDelegate?.addlog(logrecord: "Mocup dispatch: no more scheduled task in queue")
                updatestatuslightDelegate?.updatestatuslight(color: .red)
                return
            }
            updatestatuslightDelegate?.updatestatuslight(color: .yellow)
            self.dispatchtasktest(Int(seconds))
            // Set reference to schedule for later cancel if any
            ViewControllerReference.shared.dispatchTaskWaiting = self.pendingRequestWorkItem
            return
        }
        guard seconds > 0 else {
            self.logDelegate?.addlog(logrecord: "Dispatch: no more scheduled task in queue")
            updatestatuslightDelegate?.updatestatuslight(color: .red)
            return
        }
        self.dispatchtask(Int(seconds))
        ViewControllerReference.shared.scheduledTask = self.sortedandexpanded?.firstscheduledtask()
        ViewControllerReference.shared.dispatchTaskWaiting = self.pendingRequestWorkItem
        updatestatuslightDelegate?.updatestatuslight(color: .green)
    }
}
