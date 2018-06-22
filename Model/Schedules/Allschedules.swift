//
//  Allschedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 06.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

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
    weak var allschedulesDelegate: GetSchedulesSortedAndExpanded? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
    var schedulessortedandexpanded: ScheduleSortedAndExpand? {
        return allschedulesDelegate?.getschedulessortedandexpanded()
    }
}

class Allschedules {

    // Configurations object
    private var allschedules: [ConfigurationSchedule]?
    private var allprofiles: [String]?

    private func getprofilenames() {
        let profile = Files(root: .profileRoot)
        self.allprofiles = profile.getDirectorysStrings()
    }

    private func readallschedules() {
        guard self.allprofiles != nil else { return }
        var configurationschedule: [ConfigurationSchedule]?
        for i in 0 ..< self.allprofiles!.count {
            let profilename = self.allprofiles![i]
            if self.allschedules == nil {
                self.allschedules = []
            }
            if profilename == "Default profile" {
                configurationschedule = PersistentStorageAPI(profile: nil).getScheduleandhistory(nolog: true)
            } else {
                configurationschedule = PersistentStorageAPI(profile: profilename).getScheduleandhistory(nolog: true)
            }
            guard configurationschedule != nil else { return }
            for j in 0 ..< configurationschedule!.count {
                configurationschedule![j].profilename = profilename
                self.allschedules!.append(configurationschedule![j])
            }
        }
    }

    func getallschedules() -> [ConfigurationSchedule]? {
        return self.allschedules
    }

    init() {
        self.getprofilenames()
        self.readallschedules()
    }
}
