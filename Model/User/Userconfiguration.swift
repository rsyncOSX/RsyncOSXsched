//
//  userconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity function_body_length

import Foundation

// Reading userconfiguration from file into RsyncOSX
struct Userconfiguration {
    private func readUserconfiguration(dict: NSDictionary) {
        // Another version of rsync
        if let version3rsync = dict.value(forKey: DictionaryStrings.version3Rsync.rawValue) as? Int {
            if version3rsync == 1 {
                ViewControllerReference.shared.rsyncversion3 = true
            } else {
                ViewControllerReference.shared.rsyncversion3 = false
            }
        }
        // Detailed logging
        if let detailedlogging = dict.value(forKey: DictionaryStrings.detailedlogging.rawValue) as? Int {
            if detailedlogging == 1 {
                ViewControllerReference.shared.detailedlogging = true
            } else {
                ViewControllerReference.shared.detailedlogging = false
            }
        }
        // Optional path for rsync
        if let rsyncPath = dict.value(forKey: DictionaryStrings.rsyncPath.rawValue) as? String {
            ViewControllerReference.shared.localrsyncpath = rsyncPath
        }
        // Temporary path for restores single files or directory
        if let restorePath = dict.value(forKey: DictionaryStrings.restorePath.rawValue) as? String {
            if restorePath.count > 0 {
                ViewControllerReference.shared.temporarypathforrestore = restorePath
            } else {
                ViewControllerReference.shared.temporarypathforrestore = nil
            }
        }
        // Paths rsyncOSX and RsyncOSXsched
        if let pathrsyncosx = dict.value(forKey: DictionaryStrings.pathrsyncosx.rawValue) as? String {
            if pathrsyncosx.isEmpty == true {
                ViewControllerReference.shared.pathrsyncosx = nil
            } else {
                ViewControllerReference.shared.pathrsyncosx = pathrsyncosx
            }
        }
        if let pathrsyncosxsched = dict.value(forKey: DictionaryStrings.pathrsyncosxsched.rawValue) as? String {
            if pathrsyncosxsched.isEmpty == true {
                ViewControllerReference.shared.pathrsyncosxsched = nil
            } else {
                ViewControllerReference.shared.pathrsyncosxsched = pathrsyncosxsched
            }
        }
        if let environment = dict.value(forKey: DictionaryStrings.environment.rawValue) as? String {
            ViewControllerReference.shared.environment = environment
        }
        if let environmentvalue = dict.value(forKey: DictionaryStrings.environmentvalue.rawValue) as? String {
            ViewControllerReference.shared.environmentvalue = environmentvalue
        }
        if let sshkeypathandidentityfile = dict.value(forKey: DictionaryStrings.sshkeypathandidentityfile.rawValue) as? String {
            ViewControllerReference.shared.sshkeypathandidentityfile = sshkeypathandidentityfile
        }
        if let sshport = dict.value(forKey: DictionaryStrings.sshport.rawValue) as? Int {
            ViewControllerReference.shared.sshport = sshport
        }
        if let monitornetworkconnection = dict.value(forKey: DictionaryStrings.monitornetworkconnection.rawValue) as? Int {
            if monitornetworkconnection == 1 {
                ViewControllerReference.shared.monitornetworkconnection = true
            } else {
                ViewControllerReference.shared.monitornetworkconnection = false
            }
        }
        if let json = dict.value(forKey: DictionaryStrings.json.rawValue) as? Int {
            if json == 1 {
                ViewControllerReference.shared.json = true
            } else {
                ViewControllerReference.shared.json = false
            }
        }
    }

    init(userconfigRsyncOSX: [NSDictionary]) {
        if userconfigRsyncOSX.count > 0 {
            self.readUserconfiguration(dict: userconfigRsyncOSX[0])
        }
    }
}
