//
//  ViewControllerReference.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 05.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerReference {
    // Creates a singelton of this class
    class var shared: ViewControllerReference {
        struct Singleton {
            static let instance = ViewControllerReference()
        }
        return Singleton.instance
    }

    // Proess reference
    var process: Process?
    // Reference to waiting tasks, required for cancel task
    var timerTaskWaiting: Timer?
    var dispatchTaskWaiting: DispatchWorkItem?
    // Temporary storage of the first scheduled task
    var scheduledTask: NSDictionary?
    // True if version 3.2.1 of rsync in /usr/local/bin
    var rsyncversion3: Bool = false
    // Optional path to rsync
    var localrsyncpath: String?
    // Detailed logging
    var detailedlogging: Bool = true
    // Reference to the Operation object
    // Reference is set in when Scheduled task is executed
    var completeoperation: CompleteScheduledOperation?
    // rsync command
    var rsync: String = "rsync"
    var usrbinrsync: String = "/usr/bin/rsync"
    var usrlocalbinrsync: String = "/usr/local/bin/rsync"
    var configpath: String = "/Rsync/"
    // Loggfile
    var logname: String = "schedulelogg"
    var viewControllermain: NSViewController?
    // Paths
    var pathrsyncosx: String?
    var pathrsyncosxsched: String?
    let namersyncosx: String = "RsyncOSX.app"
    // log file
    var fileURL: URL?
    // String tasks
    var synchronize: String = "synchronize"
    var snapshot: String = "snapshot"
    var syncremote: String = "syncremote"
    var synctasks: Set<String>
    // Mac serialnumer
    var macserialnumber: String?
    // String for new version
    var URLnewVersion: String?
    // Mark number of days since last backup
    var marknumberofdayssince: Double = 5
    // Automatic execute local configurations in menuapp when mounting local volumes
    var automaticexecutelocalvolumes: Bool = false
    // Setting environmentvariable for Process object
    var environment: String?
    var environmentvalue: String?
    // Global SSH parameters
    var sshport: Int?
    var sshkeypathandidentityfile: String?
    // Temporary path for restore
    var temporarypathforrestore: String?
    // Loaddataonstart
    var loaddataonstart: Loaddataonstart?

    init() {
        self.synctasks = Set<String>()
        self.synctasks = [self.synchronize, self.snapshot, self.syncremote]
    }
}
