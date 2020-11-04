//
//  Allschedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 06.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

import Cocoa
import Foundation

// Protocol for returning object configurations data
protocol GetSchedulesSortedAndExpanded: AnyObject {
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
    var schedulesNSDictionary: [NSMutableDictionary]?
    var allprofiles: [String]?
    var alloffsiteservers: [String]?

    private func getprofilenames() {
        let profile = Catalogsandfiles(profileorsshrootpath: .profileroot)
        self.allprofiles = profile.getcatalogsasstringnames()
    }

    private func readallschedules() {
        var configurationschedule: [ConfigurationSchedule]?
        for i in 0 ..< (self.allprofiles?.count ?? 0) {
            let profilename = self.allprofiles?[i]
            if self.allschedules == nil { self.allschedules = [] }
            configurationschedule = PersistentStorageScheduling(profile: profilename, writeonly: false).getScheduleandhistory(nolog: true)
            for j in 0 ..< (configurationschedule?.count ?? 0) {
                configurationschedule?[j].profilename = profilename
                let offsiteserver = configurationschedule?[j].offsiteserver ?? ""
                let ifadded = self.alloffsiteservers?.filter { $0 == offsiteserver }
                if ifadded!.count == 0 {
                    if offsiteserver.isEmpty == true || offsiteserver != "localhost" {
                        self.alloffsiteservers?.append(offsiteserver)
                    }
                }
                if let configurationschedule = configurationschedule?[j] {
                    self.allschedules?.append(configurationschedule)
                }
            }
        }
    }

    // Function is reading Schedule plans and transform plans to
    // array of NSDictionary.
    // - returns : none
    private func setallscheduledtasksNSDictionary() {
        var data = [NSMutableDictionary]()
        let scheduletypes: Set<String> = [Scheduletype.daily.rawValue, Scheduletype.weekly.rawValue, Scheduletype.once.rawValue]
        for i in 0 ..< (self.allschedules?.count ?? 0) where
            self.allschedules?[i].dateStop != nil && scheduletypes.contains(self.allschedules?[i].schedule ?? "")
        {
            let dict: NSMutableDictionary = [
                "dateStart": self.allschedules?[i].dateStart ?? "",
                "dateStop": self.allschedules?[i].dateStop ?? "",
                "hiddenID": self.allschedules?[i].hiddenID ?? -1,
                "schedule": self.allschedules?[i].schedule ?? "",
                "profilename": self.allschedules?[i].profilename ?? NSLocalizedString("Default profile", comment: "default profile"),
            ]
            data.append(dict as NSMutableDictionary)
        }
        self.schedulesNSDictionary = data
    }

    init() {
        self.getprofilenames()
        self.alloffsiteservers = [String]()
        self.readallschedules()
        self.setallscheduledtasksNSDictionary()
    }
}
