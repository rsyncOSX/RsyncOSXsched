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
    var allschedulesDelegate: GetSchedulesSortedAndExpanded? {
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
    private var alloffsiteservers: [String]?

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
            if profilename == "Default profile" {
                configurationschedule = PersistentStorageAPI(profile: nil).getScheduleandhistory(nolog: true)
            } else {
                configurationschedule = PersistentStorageAPI(profile: profilename).getScheduleandhistory(nolog: true)
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

    func getallschedules() -> [ConfigurationSchedule]? {
        return self.allschedules
    }

    func getalloffsiteservers() -> [String]? {
        return self.alloffsiteservers
    }

    init() {
        self.getprofilenames()
        self.alloffsiteservers = [String]()
        self.readallschedules()
    }
}
