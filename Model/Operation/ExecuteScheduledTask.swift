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

final class ExecuteScheduledTask: SetSchedules, SetConfigurations, ScheduledTaskAnimation, Setlog {
    private func executetask() {
        let outputprocess = OutputProcess()
        var arguments: [String]?
        weak var updatestatuslightDelegate: Updatestatuslight?
        weak var tcpconnectionsDelegate: GetTCPconnections?
        weak var reloaddataDelegate: ReloadData?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        reloaddataDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        tcpconnectionsDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        var config: Configuration?
        // Get the first job of the queue
        if let dict: NSDictionary = ViewControllerReference.shared.scheduledTask {
            let profilename = dict.value(forKey: "profilename") as? String
            if profilename!.isEmpty || profilename! == NSLocalizedString("Default profile", comment: "default profile") {
                reloaddataDelegate?.reloaddata(profilename: nil)
            } else {
                reloaddataDelegate?.reloaddata(profilename: profilename)
            }
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                let getconfigurations: [Configuration]? = configurations?.getConfigurations()
                guard getconfigurations != nil else { return }
                let configArray = getconfigurations!.filter { ($0.hiddenID == hiddenID) }
                guard configArray.count > 0 else { return }
                config = configArray[0]
                // Inform and notify
                self.scheduletaskanimation?.startanimation()
                if hiddenID >= 0, config != nil {
                    if let remoteserver = config?.offsiteServer {
                        guard tcpconnectionsDelegate?.gettcpconnections()?.checkremoteconnection(remoteserver: remoteserver) == true else { return }
                    }
                    arguments = RsyncParameters().argumentsRsync(config: config!)
                    if let arguments = arguments {
                        // Setting reference to finalize the job, finalize job is done when rsynctask ends (in process termination)
                        ViewControllerReference.shared.completeoperation = CompleteScheduledOperation(dict: dict)
                        self.logDelegate?.addlog(logrecord: NSLocalizedString("Executing task in profile", comment: "Execute") + " " + profilename! + " with ID " + config!.backupID)
                        weak var sendoutputprocess: SendOutputProcessreference?
                        sendoutputprocess = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
                        let process = ProcessCmd(command: nil, arguments: arguments)
                        globalMainQueue.async {
                            process.executeProcess(outputprocess: outputprocess)
                            sendoutputprocess?.sendoutputprocessreference(outputprocess: outputprocess)
                        }
                    }
                }
            } else {
                updatestatuslightDelegate?.updatestatuslight(color: .red)
                self.logDelegate?.addlog(logrecord: NSLocalizedString("No hiddenID in dictionary", comment: "Execute"))
                _ = Notifications().showNotification(message: NSLocalizedString("Scheduled backup did not execute", comment: "Execute"))
            }
        } else {
            updatestatuslightDelegate?.updatestatuslight(color: .red)
            self.logDelegate?.addlog(logrecord: "No record for scheduled task")
            _ = Notifications().showNotification(message: NSLocalizedString("Scheduled backup did not execute", comment: "Execute"))
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
