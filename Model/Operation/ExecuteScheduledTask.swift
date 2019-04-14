//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length function_body_length

import Foundation

// The Operation object to execute a scheduled job.
// The object get the hiddenID for the job, reads the
// rsync parameters for the job, creates a object to finalize the
// job after execution as logging. The reference to the finalize object
// is set in the static object. The finalize object is invoked
// when the job discover (observs) the termination of the process.

final class ExecuteScheduledTask: SetSchedules, SetConfigurations, SetScheduledTask, Setlog {

    private func executetask() {
        let outputprocess = OutputProcess()
        var arguments: [String]?
        weak var updatestatuslightDelegate: Updatestatuslight?
        weak var tcpconnectionsDelegate: GetTCPconnections?
        weak var reloaddataDelegate: ReloadData?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        reloaddataDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        tcpconnectionsDelegate =  ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        var config: Configuration?
        // Get the first job of the queue
        if let dict: NSDictionary = ViewControllerReference.shared.scheduledTask {
            let profilename = dict.value(forKey: "profilename") as? String
            if profilename!.isEmpty || profilename! == "Default profile" {
                reloaddataDelegate?.reloaddata(profilename: nil)
            } else {
                reloaddataDelegate?.reloaddata(profilename: profilename)
            }
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                let getconfigurations: [Configuration]? = configurations?.getConfigurations()
                guard getconfigurations != nil else { return }
                let configArray = getconfigurations!.filter({return ($0.hiddenID == hiddenID)})
                guard configArray.count > 0 else { return }
                config = configArray[0]
                // Inform and notify
                self.scheduleJob?.start()
                if hiddenID >= 0 && config != nil {
                    if let remoteserver = config?.offsiteServer {
                        guard tcpconnectionsDelegate?.gettcpconnections()?.checkremoteconnection(remoteserver: remoteserver) == true else { return }
                    }
                    arguments = RsyncParametersProcess().argumentsRsync(config!)
                    // Setting reference to finalize the job, finalize job is done when rsynctask ends (in process termination)
                    ViewControllerReference.shared.completeoperation = CompleteScheduledOperation(dict: dict)
                    if arguments != nil {
                        self.logDelegate?.addlog(logrecord: "Executing task in profile " + profilename! + " with ID " + config!.backupID)
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

    init() {
       self.executetask()
    }
}
