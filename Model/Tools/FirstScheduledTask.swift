//
//  FirstScheduledTask.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 13/09/2019.
//  Copyright © 2019 Maxim. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

struct FirsScheduledTask: GetAllSchedules {
    var taskintime: String?
    init() {
        if let dict = self.schedulessortedandexpanded?.sortedschedules?[0] {
            let hiddenID = dict.value(forKey: "hiddenID") as? Int ?? -1
            let profilename = dict.value(forKey: "profilename") as? String ?? NSLocalizedString("Default profile", comment: "default profile")
            let dateStart = dict.value(forKey: "dateStart") as? Date
            let time = self.schedulessortedandexpanded!.sortandcountscheduledonetask(hiddenID: hiddenID, profilename: profilename, dateStart: dateStart, number: true)
            self.taskintime = NSLocalizedString("First scheduled task:", comment: "firstask") + " " + profilename + " " + NSLocalizedString("in", comment: "firstask") + " " + time
        }
    }
}
