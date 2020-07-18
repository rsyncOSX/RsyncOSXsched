//
//  ExecuteScheduledTaskShellOut.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 18/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

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

    /*
     func executetasknow() {
         if let index = self.index {
             // Execute pretask
             if self.configurations?.getConfigurations()[index].executepretask == 1 {
                 do {
                     try self.executepretask()
                 } catch let e {
                     let error = e as? ShellOutError
                     let outputprocess = OutputProcess()
                     outputprocess.addlinefromoutput(str: "ShellOut: pretask fault, aborting")
                     outputprocess.addlinefromoutput(str: error?.message ?? "")
                     _ = Logging(outputprocess, true)
                     self.error = true
                 }
             }

             guard self.error == false else { return }
             self.outputprocess = OutputProcessRsync()
             if let arguments = self.configurations?.arguments4rsync(index: index, argtype: .arg) {
                 if #available(OSX 10.14, *) {
                     let process = RsyncVerify(arguments: arguments, config: (self.configurations?.getConfigurations()[index])!)
                     process.setdelegate(object: self)
                     process.executeProcess(outputprocess: self.outputprocess)
                     self.startstopindicators?.startIndicatorExecuteTaskNow()
                     self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
                 } else {
                     let process = Rsync(arguments: arguments)
                     process.setdelegate(object: self)
                     process.executeProcess(outputprocess: self.outputprocess)
                     self.startstopindicators?.startIndicatorExecuteTaskNow()
                     self.setprocessDelegate?.sendoutputprocessreference(outputprocess: self.outputprocess)
                 }
             }
         }
     }
     */
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
