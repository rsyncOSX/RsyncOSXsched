//
//  userconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Foundation

// Reading userconfiguration from file into RsyncOSX
struct Userconfiguration {
    private func readUserconfiguration(dict: NSDictionary) {
        // Another version of rsync
        if let version3rsync = dict.value(forKey: "version3Rsync") as? Int {
            if version3rsync == 1 {
                ViewControllerReference.shared.rsyncversion3 = true
            } else {
                ViewControllerReference.shared.rsyncversion3 = false
            }
        }
        // Detailed logging
        if let detailedlogging = dict.value(forKey: "detailedlogging") as? Int {
            if detailedlogging == 1 {
                ViewControllerReference.shared.detailedlogging = true
            } else {
                ViewControllerReference.shared.detailedlogging = false
            }
        }
        // Optional path for rsync
        if let rsyncPath = dict.value(forKey: "rsyncPath") as? String {
            ViewControllerReference.shared.localrsyncpath = rsyncPath
        }
        // Paths rsyncOSX and RsyncOSXsched
        if let pathrsyncosx = dict.value(forKey: "pathrsyncosx") as? String {
            ViewControllerReference.shared.pathrsyncosx = pathrsyncosx
        }
        if let pathrsyncosxsched = dict.value(forKey: "pathrsyncosxsched") as? String {
            ViewControllerReference.shared.pathrsyncosxsched = pathrsyncosxsched
        }
        // Operation object
        // Default is dispatch
        if let operation = dict.value(forKey: "operation") as? String {
            switch operation {
            case "dispatch":
                ViewControllerReference.shared.operation = .dispatch
            case "timer":
                ViewControllerReference.shared.operation = .timer
            default:
                ViewControllerReference.shared.operation = .dispatch
            }
        }
        if let automaticexecutelocalvolumes = dict.value(forKey: "automaticexecutelocalvolumes") as? Int {
            if automaticexecutelocalvolumes == 1 {
                ViewControllerReference.shared.automaticexecutelocalvolumes = true
            } else {
                ViewControllerReference.shared.automaticexecutelocalvolumes = false
            }
        }
        if let environment = dict.value(forKey: "environment") as? String {
            ViewControllerReference.shared.environment = environment
        }
        if let environmentvalue = dict.value(forKey: "environmentvalue") as? String {
            ViewControllerReference.shared.environmentvalue = environmentvalue
        }
    }

    init(userconfigRsyncOSX: [NSDictionary]) {
        if userconfigRsyncOSX.count > 0 {
            self.readUserconfiguration(dict: userconfigRsyncOSX[0])
        }
    }
}
