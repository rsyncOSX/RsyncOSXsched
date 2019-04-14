//
//  ExecuteScheduledTaskNow.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 14/04/2019.
//  Copyright © 2019 Maxim. All rights reserved.
//

import Foundation

final class ExecuteScheduledTaskNow: SetSchedules, SetConfigurations, SetScheduledTask, Setlog {

    private func executetasknow(dict: NSDictionary) {
        let outputprocess = OutputProcess()
        var arguments: [String]?
        weak var updatestatuslightDelegate: Updatestatuslight?
        weak var tcpconnectionsDelegate: GetTCPconnections?
        weak var reloaddataDelegate: ReloadData?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        reloaddataDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        tcpconnectionsDelegate =  ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        var config: Configuration?
        
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
    }

    init(dict: NSDictionary) {
        self.executetasknow(dict: dict)
    }
}
