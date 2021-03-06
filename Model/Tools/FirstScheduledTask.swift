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
    var firsscheduledtaskintime: String?
    init() {
        guard self.schedulessortedandexpanded?.sortedschedules?.count ?? 0 > 0 else { return }
        if let dict = self.schedulessortedandexpanded?.sortedschedules?[0] {
            let hiddenID = dict.value(forKey: "hiddenID") as? Int ?? -1
            let profilename = dict.value(forKey: DictionaryStrings.profilename.rawValue) as? String ?? NSLocalizedString("Default profile", comment: "default profile")
            if let time = self.schedulessortedandexpanded?.sortandcountscheduledonetask(hiddenID, profilename: profilename, number: true) {
                self.firsscheduledtaskintime = NSLocalizedString("First scheduled task:", comment: "firstask") + " " + profilename + " " + NSLocalizedString("in", comment: "firstask") + " " + time
            }
        }
    }
}
