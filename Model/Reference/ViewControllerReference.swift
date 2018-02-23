//
//  ViewControllerReference.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 05.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation
import Cocoa

class ViewControllerReference {

    // Creates a singelton of this class
    class var  shared: ViewControllerReference {
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
    var rsyncVer3: Bool = false
    // Optional path to rsync
    var rsyncPath: String?
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
    let namersyncosssched: String = "RsyncOSXsched.app"
    // Set true if test in menu app
    var executeschedulesmocup: Bool = false
    // log file
    var fileURL: URL?
    // Execute scheduled tasks in menu app, default off
    var executescheduledtasksmenuapp: Bool = false
}
