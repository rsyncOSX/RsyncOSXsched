//
//  GetConfig.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 19/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation
struct GetConfig: SetSchedules, SetConfigurations {
    weak var reloaddataDelegate: ReloadData?
    var config: Configuration?
    var dict: NSDictionary?
    var profilename: String?
    var shellout: Bool = false

    init() {
        self.reloaddataDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        if let dict: NSDictionary = ViewControllerReference.shared.scheduledTask {
            self.dict = dict
            if let profilename = dict.value(forKey: "profilename") as? String {
                self.reloaddataDelegate?.reloaddata(profilename: profilename)
                self.profilename = profilename
            } else {
                self.reloaddataDelegate?.reloaddata(profilename: nil)
                self.profilename = nil
            }
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                guard hiddenID >= 0 else {
                    self.config = nil
                    return
                }
                let getconfigurations: [Configuration]? = configurations?.getConfigurations()
                guard getconfigurations != nil else { return }
                let configArray = getconfigurations!.filter { ($0.hiddenID == hiddenID) }
                guard configArray.count > 0 else { return }
                self.config = configArray[0]
                if (self.config?.pretask ?? "").isEmpty == false, self.config?.executepretask ?? 0 == 1 {
                    self.shellout = true
                }
            }
        } else {
            self.config = nil
        }
    }
}
