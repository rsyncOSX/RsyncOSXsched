//
//  ExecuteScheduledTaskShellOut.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 18/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import ShellOut

final class ExecuteScheduledTaskShellOut: ExecuteScheduledTask {
    var error: Bool = false
    var config: Configuration?

    func executepretask() throws {
        if let config = self.config {
            if let pretask = config.pretask {
                let task = try shellOut(to: pretask)
                self.logDelegate?.addlog(logrecord: "ShellOut: execute pretask")
                if task.self.contains("error"), (config.haltshelltasksonerror ?? 0) == 1 {
                    self.logDelegate?.addlog(logrecord: "ShellOut: pretask containes error, aborting")
                    self.error = true
                }
            }
        }
    }

    func executeposttask() throws {
        if let config = self.config {
            if let posttask = config.posttask {
                let task = try shellOut(to: posttask)
                self.logDelegate?.addlog(logrecord: "ShellOut: execute posttak")
                if task.self.contains("error"), (config.haltshelltasksonerror ?? 0) == 1 {
                    self.logDelegate?.addlog(logrecord: "ShellOut: posstak containes error, aborting")
                }
            }
        }
    }

    override func executetask() {
        let outputprocess = OutputProcess()
        weak var updatestatuslightDelegate: Updatestatuslight?
        weak var tcpconnectionsDelegate: GetTCPconnections?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        tcpconnectionsDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain

        if let config = GetConfig().config, let dict = GetConfig().dict {
            self.config = config
            // Execute pretask
            if config.executepretask == 1 {
                do {
                    try self.executepretask()
                } catch let e {
                    let error = e as? ShellOutError
                    self.logDelegate?.addlog(logrecord: "ShellOut: pretask fault, aborting")
                    self.logDelegate?.addlog(logrecord: error?.description ?? "")
                    self.error = true
                }
            }
            guard self.error == false else { return }
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
                let process = RsyncProcessCmdClosure(arguments: arguments, config: config, processtermination: self.processtermination)
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

    deinit {
        // Execute posttask
        guard self.error == false else { return }
        if let config = self.config {
            if config.executeposttask == 1 {
                do {
                    try self.executeposttask()
                } catch let e {
                    let error = e as? ShellOutError
                    self.logDelegate?.addlog(logrecord: "ShellOut: posttask fault")
                    self.logDelegate?.addlog(logrecord: error?.description ?? "")
                    self.error = true
                }
            }
        }
    }
}
