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

    func executepretask() throws {
        if let config = self.config {
            if let pretask = config.pretask {
                let task = try shellOut(to: pretask)
                // let outputprocess = OutputProcess()
                // outputprocess.addlinefromoutput(str: "ShellOut: execute pretask")
                // outputprocess.addlinefromoutput(str: task.self)
                // _ = Logging(outputprocess, true)
                if task.self.contains("error"), (config.haltshelltasksonerror ?? 0) == 1 {
                    let outputprocess = OutputProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: pretask containes error, aborting")
                    // _ = Logging(outputprocess, true)
                    self.error = true
                }
            }
        }
    }

    func executeposttask() throws {
        if let config = self.config {
            if let posttask = config.posttask {
                let task = try shellOut(to: posttask)
                // let outputprocess = OutputProcess()
                // outputprocess.addlinefromoutput(str: "ShellOut: execute posttask")
                // outputprocess.addlinefromoutput(str: task.self)
                // _ = Logging(outputprocess, true)
                if task.self.contains("error"), (config.haltshelltasksonerror ?? 0) == 1 {
                    let outputprocess = OutputProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: posstak containes error")
                    // _ = Logging(outputprocess, true)
                }
            }
        }
    }

    override func executetask() {
        let outputprocess = OutputProcess()
        var arguments: [String]?
        weak var updatestatuslightDelegate: Updatestatuslight?
        weak var tcpconnectionsDelegate: GetTCPconnections?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        tcpconnectionsDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain

        if let config = GetConfig().config, let dict = GetConfig().dict {
            // Execute pretask
            if config.executepretask == 1 {
                do {
                    try self.executepretask()
                } catch let e {
                    let error = e as? ShellOutError
                    let outputprocess = OutputProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: pretask fault, aborting")
                    outputprocess.addlinefromoutput(str: error?.message ?? "")
                    // _ = Logging(outputprocess, true)
                    self.error = true
                }
            }
            guard self.error == false else { return }
            // Inform and notify
            self.scheduletaskanimation?.startanimation()
            if config.offsiteServer.isEmpty == false {
                guard tcpconnectionsDelegate?.gettcpconnections()?.checkremoteconnection(remoteserver: config.offsiteServer) == true else { return }
            }
            arguments = RsyncParameters().argumentsRsync(config: config)
            if let arguments = arguments {
                // Setting reference to finalize the job, finalize job is done when rsynctask ends (in process termination)
                ViewControllerReference.shared.completeoperation = CompleteScheduledOperation(dict: dict)
                let profilename = GetConfig().profilename
                let message = NSLocalizedString("Executing task in profile", comment: "Execute") + " " + (profilename ?? "Default profile") + " with ID " + config.backupID
                self.logDelegate?.addlog(logrecord: message)
                weak var sendoutputprocess: SendOutputProcessreference?
                sendoutputprocess = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
                let process = ProcessCmd(command: nil, arguments: arguments)
                globalMainQueue.async {
                    process.executeProcess(outputprocess: outputprocess)
                    sendoutputprocess?.sendoutputprocessreference(outputprocess: outputprocess)
                }

            } else {
                updatestatuslightDelegate?.updatestatuslight(color: .red)
                self.logDelegate?.addlog(logrecord: "No record for scheduled task")
                _ = Notifications().showNotification(message: NSLocalizedString("Scheduled backup did not execute", comment: "Execute"))
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
                    let outputprocess = OutputProcess()
                    outputprocess.addlinefromoutput(str: "ShellOut: posttask fault")
                    outputprocess.addlinefromoutput(str: error?.message ?? "")
                    // _ = Logging(outputprocess, true)
                }
            }
        }
    }
}
