//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

// The Operation object to execute a scheduled job.
// The object get the hiddenID for the job, reads the
// rsync parameters for the job, creates a object to finalize the
// job after execution as logging. The reference to the finalize object
// is set in the static object. The finalize object is invoked
// when the job discover (observs) the termination of the process.

class ExecuteScheduledTask: SetSchedules, SetConfigurations, ScheduledTaskAnimation, Setlog {
    func executetask() {
        let outputprocess = OutputProcess()
        weak var updatestatuslightDelegate: Updatestatuslight?
        weak var tcpconnectionsDelegate: GetTCPconnections?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        tcpconnectionsDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        if let config = GetConfig().config, let dict = GetConfig().dict {
            // Inform and notify
            self.scheduletaskanimation?.startanimation()
            if config.offsiteServer.isEmpty == false {
                guard tcpconnectionsDelegate?.gettcpconnections()?.checkremoteconnection(remoteserver: config.offsiteServer) == true else { return }
            }
            if let arguments = RsyncParameters().argumentsRsync(config: config) {
                // Setting reference to finalize the job, finalize job is done when rsynctask ends (in process termination)
                ViewControllerReference.shared.completeoperation = CompleteScheduledOperation(dict: dict)
                let profilename = GetConfig().profilename
                let message = NSLocalizedString("Executing task in profile", comment: "Execute") + " " + (profilename ?? "Default profile") + " with ID " + config.backupID
                self.logDelegate?.addlog(logrecord: message)
                weak var sendoutputprocess: SendOutputProcessreference?
                sendoutputprocess = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
                let process = ProcessCmd(arguments: arguments)
                globalMainQueue.async {
                    process.executeProcess(outputprocess: outputprocess)
                    sendoutputprocess?.sendoutputprocessreference(outputprocess: outputprocess)
                }

            } else {
                updatestatuslightDelegate?.updatestatuslight(color: .red)
                self.logDelegate?.addlog(logrecord: "No record for scheduled task")
                Notifications().showNotification(message: NSLocalizedString("Scheduled backup did not execute", comment: "Execute"))
            }
        }
    }

    init() {
        self.executetask()
    }

    init(dict: NSDictionary) {
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        ViewControllerReference.shared.dispatchTaskWaiting = nil
        ViewControllerReference.shared.scheduledTask = dict
        self.executetask()
    }
}
