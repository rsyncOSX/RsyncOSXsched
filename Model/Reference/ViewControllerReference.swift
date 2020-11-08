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
    // New RsynOSX config files and path
    var newconfigpath: String = "/.rsyncosx/"
    var usenewconfigpath: Bool = true
    // Plistnames and key
    var scheduleplist: String = "/scheduleRsync.plist"
    var schedulekey: String = "Schedule"
    var configurationsplist: String = "/configRsync.plist"
    var configurationskey: String = "Catalogs"
    var userconfigplist: String = "/config.plist"
    var userconfigkey: String = "config"
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
    // Setting environmentvariable for Process object
    var environment: String?
    var environmentvalue: String?
    // Global SSH parameters
    var sshport: Int?
    var sshkeypathandidentityfile: String?
    // Temporary path for restore
    var temporarypathforrestore: String?
    // Check for network changes
    var monitornetworkconnection: Bool = false
    // Read JSON
    var json: Bool = false
    // Read plist, convert to JSON button enabled
    var convertjsonbutton: Bool = false
    // JSON names
    var fileschedulesjson = "schedules.json"
    var fileconfigurationsjson = "configurations.json"
    // reference to app delegate
    var appdelegate: AnyObject?

    init() {
        self.synctasks = Set<String>()
        self.synctasks = [self.synchronize, self.snapshot, self.syncremote]
    }
}
