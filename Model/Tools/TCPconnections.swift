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
    var client: TCPClient?

    // Test for TCP connection
    func testTCPconnection(_ host: String, port: Int, timeout: Int) -> Bool {
        self.client = TCPClient(address: host, port: Int32(port))
        guard let client = client else { return true }
        switch client.connect(timeout: timeout) {
        case .success:
            return true
        default:
            return false
        }
    }

    // Testing all remote servers.
    // Adding connection true or false in array[bool]
    // Do the check in background que, reload table in global main queue
    func testAllremoteserverConnections(offsiteservers: [String]?) {
        guard offsiteservers != nil else { return }
        globalBackgroundQueue.async { () -> Void in
            weak var probablynoconnectionsDelegate: Updatestatustcpconnections?
            probablynoconnectionsDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
            let port: Int = 22
            for i in 0 ..< offsiteservers!.count where offsiteservers![i].isEmpty == false {
                let success = self.testTCPconnection(offsiteservers![i], port: port, timeout: 1)
                if success == false {
                    probablynoconnectionsDelegate?.updatestatustcpconnections()
                    let loginfo = NSLocalizedString("No connection with server:", comment: "loginfo")
                    self.logDelegate?.addlog(logrecord: loginfo + " " + offsiteservers![i])
                    if self.noconnections == nil {
                        self.noconnections = [String]()
                        self.noconnections?.append(offsiteservers![i])
                    } else {
                        self.noconnections?.append(offsiteservers![i])
                    }
                }
            }
        }
    }

    func checkremoteconnection(remoteserver: String) -> Bool {
        guard self.noconnections != nil else { return true }
        self.logDelegate?.addlog(logrecord: "Checking for connection to remote server")
        guard noconnections!.filter({ ($0 == remoteserver) }).count < 1 else {
            let loginfo = NSLocalizedString("No connection, bailed out...", comment: "loginfo")
            let noexecuteinfo = NSLocalizedString("Scheduled backup did not execute", comment: "loginfo")
            self.logDelegate?.addlog(logrecord: loginfo)
            Notifications().showNotification(message: noexecuteinfo)
            return false
        }
        return true
    }
}
