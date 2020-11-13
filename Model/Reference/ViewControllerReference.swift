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
    weak var appdelegate: AnyObject?

    init() {
        self.synctasks = Set<String>()
        self.synctasks = [self.synchronize, self.snapshot, self.syncremote]
    }
}

enum DictionaryStrings: String {
    case localCatalog
    case profile
    case remoteCatalog
    case offsiteServer
    case task
    case backupID
    case daysID
    case dateExecuted
    case offsiteUsername
    case markdays
    case selectCellID
    case hiddenID
    case offsiteCatalog
    case dateStart
    case schedule
    case dateStop
    case resultExecuted
    case snapshotnum
    case snapdayoffweek
    case dateRun
    case executepretask
    case executeposttask
    case snapCellID
    case localCatalogCellID
    case offsiteCatalogCellID
    case offsiteUsernameID
    case offsiteServerCellID
    case backupIDCellID
    case runDateCellID
    case haltshelltasksonerror
    case taskCellID
    case parameter1
    case parameter2
    case parameter3
    case parameter4
    case parameter5
    case parameter6
    case parameter8
    case parameter9
    case parameter10
    case parameter11
    case parameter12
    case parameter13
    case parameter14
    case rsyncdaemon
    case sshport
    case snaplast
    case sshkeypathandidentityfile
    case pretask
    case posttask
    case executed
    case offsiteserver
    case version3Rsync
    case detailedlogging
    case rsyncPath
    case restorePath
    case marknumberofdayssince
    case pathrsyncosx
    case pathrsyncosxsched
    case minimumlogging
    case fulllogging
    case environment
    case environmentvalue
    case haltonerror
    case monitornetworkconnection
    case json
    case used
    case avail
    case availpercent
    case deleteCellID
    case remotecomputers
    case remoteusers
    case remotehome
    case catalogs
    case localhome
    case transferredNumber
    case sibling
    case parent
    case timetostart
    case start
    case snapshotCatalog
    case days
    case totalNumber
    case totalDirs
    case transferredNumberSizebytes
    case totalNumberSizebytes
    case newfiles
    case deletefiles
    case select
    case startsin
    case stopCellID
    case delta
    case completeCellID
    case inprogressCellID
    case profilename
}

enum NumDayofweek: Int {
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
    case Sunday = 1
}

enum StringDayofweek: String {
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday
}
