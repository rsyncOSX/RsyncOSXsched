//
//  TCPconnections.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

var globalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

var globalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: .background)
}

class TCPconnections: SetConfigurations, Delay, Setlog {

    var noconnections: [String]?

    // Test for TCP connection
    private func testTCPconnection (_ addr: String, port: Int, timeout: Int) -> (Bool, String) {
        var connectionOK: Bool = false
        var str: String = ""
        let client: TCPClient = TCPClient(addr: addr, port: port)
        let (success, errmsg) = client.connect(timeout: timeout)
        connectionOK = success
        if connectionOK {
            str = "connection OK"
        } else {
            str = errmsg
        }
        return (connectionOK, str)
    }

    // Testing all remote servers.
    // Adding connection true or false in array[bool]
    // Do the check in background que, reload table in global main queue
    func testAllremoteserverConnections(offsiteservers: [String]?) {
        guard offsiteservers != nil else { return }
        globalBackgroundQueue.async(execute: { () -> Void in
            weak var probablynoconnectionsDelegate: Updatestatustcpconnections?
            probablynoconnectionsDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
            let port: Int = 22
            for i in 0 ..< offsiteservers!.count where offsiteservers![i].isEmpty == false {
                let (success, _) = self.testTCPconnection(offsiteservers![i], port: port, timeout: 1)
                if success == false {
                    probablynoconnectionsDelegate?.updatestatustcpconnections()
                    self.logDelegate?.addlog(logrecord: "No connection with server: " + offsiteservers![i])
                    if self.noconnections == nil {
                        self.noconnections = [String]()
                        self.noconnections?.append(offsiteservers![i])
                    } else {
                        self.noconnections?.append(offsiteservers![i])
                    }
                }
            }
        })
    }

    func checkremoteconnection(remoteserver: String) -> Bool {
        guard self.noconnections != nil else { return true}
        self.logDelegate?.addlog(logrecord: "Checking for connection to remote server")
        guard noconnections!.filter({return ($0 == remoteserver)}).count < 1 else {
            self.logDelegate?.addlog(logrecord: "No connection, bailed out...")
            _ = Notifications().showNotification(message: "Scheduled backup did not execute")
            weak var processTerminationDelegate: UpdateProgress?
            processTerminationDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
            processTerminationDelegate?.processTermination()
            return false
        }
        return true
    }

    init() {
    }
}
