//
//  processCmd.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

protocol Delay {
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void)
}

extension Delay {

    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

protocol ErrorOutput: class {
    func erroroutput()
}

class ProcessCmd: Delay, SetConfigurations {

    // Number of calculated files to be copied
    var calculatedNumberOfFiles: Int = 0
    // Variable for reference to Process
    var processReference: Process?
    // Observer
    weak var notifications: NSObjectProtocol?
    // Command to be executed, normally rsync
    var command: String?
    // Arguments to command
    var arguments: [String]?
    // true if processtermination
    var termination: Bool = false
    // possible error ouput
    weak var possibleerrorDelegate: ErrorOutput?
    // Message to calling class
    weak var updateDelegate: UpdateProgress?

    func executeProcess (outputprocess: OutputProcess?) {
        let task = Process()
        // Setting the correct path for rsync
        // If self.command != nil other command than rsync to be executed
        // Other commands are either ssh or scp (from CopyFiles)
        if let command = self.command {
            task.launchPath = command
        } else {
            task.launchPath = Verifyrsyncpath().rsyncpath()
        }
        task.arguments = self.arguments
        // If there are any Environmentvariables like
        // SSH_AUTH_SOCK": "/Users/user/.gnupg/S.gpg-agent.ssh"
        if let environment = Environment() {
            task.environment = environment.environment
        }
        // Pipe for reading output from Process
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        // Observator for reading data from pipe, observer is removed when Process terminates
        self.notifications = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                            object: nil, queue: nil) { _ -> Void in
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    if outputprocess != nil {
                        outputprocess!.addlinefromoutput(str as String)
                        self.calculatedNumberOfFiles = outputprocess!.count()
                        // Send message about files
                        self.updateDelegate?.fileHandler()
                        if self.termination {
                            self.possibleerrorDelegate?.erroroutput()
                        }
                    }
                }
                outHandle.waitForDataInBackgroundAndNotify()
            }
        }
        // Observator Process termination, observer is removed when Process terminates
        self.notifications = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                            object: task, queue: nil) { _ -> Void in
            self.delayWithSeconds(0.5) {
                self.termination = true
                self.updateDelegate?.processTermination()
            }
            NotificationCenter.default.removeObserver(self.notifications as Any)
        }
        self.processReference = task
        task.launch()
    }

    // Get the reference to the Process object.
    func getProcess() -> Process? {
        return self.processReference
    }

    init(command: String?, arguments: [String]?) {
        self.command = command
        self.arguments = arguments
        self.possibleerrorDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        self.updateDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
}
