//
//  Allschedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 06.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

// Protocol for returning object configurations data
protocol GetSchedulesSortedAndExpanded: class {
    func getschedulessortedandexpanded() -> ScheduleSortedAndExpand?
}

protocol GetAllSchedules {
    var allschedulesDelegate: GetSchedulesSortedAndExpanded? { get }
    var schedulessortedandexpanded: ScheduleSortedAndExpand? { get }
}

extension GetAllSchedules {
    var allschedulesDelegate: GetSchedulesSortedAndExpanded? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
    var schedulessortedandexpanded: ScheduleSortedAndExpand? {
        return allschedulesDelegate?.getschedulessortedandexpanded()
    }
}

class Allschedules {

    // Configurations object
    var allschedules: [ConfigurationSchedule]?
    var allprofiles: [String]?
    var alloffsiteservers: [String]?

    private func getprofilenames() {
        let profile = Files(whichroot: .profileRoot, configpath: ViewControllerReference.shared.configpath)
        self.allprofiles = profile.getDirectorysStrings()
    }

    private func readallschedules() {
        guard self.allprofiles != nil else { return }
        var configurationschedule: [ConfigurationSchedule]?
        for i in 0 ..< self.allprofiles!.count {
            let profilename = self.allprofiles![i]
            if self.allschedules == nil { self.allschedules = [] }
            if profilename == NSLocalizedString("Default profile", comment: "default profile") {
                configurationschedule = PersistentStorageScheduling(profile: nil).getScheduleandhistory(nolog: true)
            } else {
                configurationschedule = PersistentStorageScheduling(profile: profilename).getScheduleandhistory(nolog: true)
            }
            if configurationschedule != nil {
                for j in 0 ..< configurationschedule!.count {
                    configurationschedule![j].profilename = profilename
                    let offsiteserver = configurationschedule![j].offsiteserver ?? ""
                    let ifadded = self.alloffsiteservers!.filter({return $0 == offsiteserver})
                    if ifadded.count == 0 {
                        if offsiteserver.isEmpty == true || offsiteserver != "localhost" {
                            self.alloffsiteservers?.append(offsiteserver)
                        }
                    }
                    self.allschedules!.append(configurationschedule![j])
                }
            }
        }
    }

    init() {
        self.getprofilenames()
        self.alloffsiteservers = [String]()
        self.readallschedules()
    }
}
