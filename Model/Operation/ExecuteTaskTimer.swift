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

class ExecuteTaskTimer: Operation, SetSchedules, SetConfigurations, SetScheduledTask, Setlog {

    override func main() {
        let outputprocess = OutputProcess()
        var arguments: [String]?
        weak var updatestatuslightDelegate: Updatestatuslight?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        var config: Configuration?
        // Get the first job of the queue
        // Get the first job of the queue
        if let dict: NSDictionary = ViewControllerReference.shared.scheduledTask {
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                self.logDelegate?.addlog(logrecord: "Executing task hiddenID: " + String(hiddenID))
                let getconfigurations: [Configuration]? = configurations?.getConfigurations()
                guard getconfigurations != nil else { return }
                let configArray = getconfigurations!.filter({return ($0.hiddenID == hiddenID)})
                guard configArray.count > 0 else { return }
                config = configArray[0]
                // Inform and notify
                self.scheduleJob?.start()
                if hiddenID >= 0 && config != nil {
                    arguments = RsyncParametersProcess().argumentsRsync(config!, dryRun: false, forDisplay: false)
                    // Setting reference to finalize the job, finalize job is done when rsynctask ends (in process termination)
                    ViewControllerReference.shared.completeoperation = CompleteScheduledOperation(dict: dict)
                    if arguments != nil {
                        weak var sendprocess: Sendprocessreference?
                        sendprocess = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
                        let process = RsyncScheduled(arguments: arguments)
                        globalMainQueue.async(execute: {
                            process.executeProcess(outputprocess: outputprocess)
                            sendprocess?.sendprocessreference(process: process.getProcess())
                            sendprocess?.sendoutputprocessreference(outputprocess: outputprocess)
                        })
                    }
                }
            } else {
                updatestatuslightDelegate?.updatestatuslight(color: .red)
                self.logDelegate?.addlog(logrecord: "No hiddenID in dictionary")
                _ = Notifications().showNotification(message: "Scheduled backup did not execute")
            }
        } else {
            updatestatuslightDelegate?.updatestatuslight(color: .red)
            self.logDelegate?.addlog(logrecord: "No record for scheduled task: ViewControllerReference.shared.scheduledTask")
            _ = Notifications().showNotification(message: "Scheduled backup did not execute")
        }
    }
}

class ExecuteTaskTimerMocup: Operation, Setlog {
    override func main() {
        weak var reloadDelegate: Reloadsortedandrefresh?
        reloadDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        reloadDelegate?.reloadsortedandrefreshtabledata()
    }
}
