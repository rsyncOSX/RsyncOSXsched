//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

protocol ReloadData: AnyObject {
    func reloaddata(profilename: String?)
}

protocol GetTCPconnections: AnyObject {
    func gettcpconnections() -> TCPconnections?
}

class ScheduleOperationDispatch: SetSchedules, SecondstoStart, Setlog {
    // Process termination and filehandler closures
    var processtermination: () -> Void
    weak var workitem: DispatchWorkItem?

    private func dispatchtaskshellout(_ seconds: Int) {
        let scheduledtask = DispatchWorkItem { () -> Void in
            _ = ExecuteScheduledTaskShellOut(processtermination: self.processtermination)
        }
        self.workitem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }

    private func dispatchtask(_ seconds: Int) {
        let scheduledtask = DispatchWorkItem { () -> Void in
            _ = ExecuteScheduledTask(processtermination: self.processtermination)
        }
        self.workitem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }

    init(processtermination: @escaping () -> Void) {
        self.processtermination = processtermination
        weak var updatestatuslightDelegate: Updatestatuslight?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        let seconds = self.secondstostart()
        guard seconds > 0 else {
            self.logDelegate?.addlog(logrecord: NSLocalizedString("Dispatch: no more scheduled task in queue", comment: "Dispatch"))
            updatestatuslightDelegate?.updatestatuslight(color: .red)
            return
        }
        let timestring = Dateandtime().timestring(seconds: seconds)
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Dispatch: setting next scheduled task in:", comment: "Dispatch") + " " + timestring)
        if GetConfig().shellout {
            self.dispatchtaskshellout(Int(seconds))
        } else {
            self.dispatchtask(Int(seconds))
        }
        // Set reference to schedule for later cancel if any
        ViewControllerReference.shared.dispatchTaskWaiting = self.workitem
        updatestatuslightDelegate?.updatestatuslight(color: .green)
    }
}
