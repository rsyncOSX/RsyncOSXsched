//
//  CheckAllConfigurations.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 19/04/2019.
//  Copyright © 2019 Maxim. All rights reserved.
//

import Foundation

class CheckAllConfigurations {

    var allprofiles: [String]?
    var allconfigurations: [Configuration]?
    var path: String?

    private func getprofilenames() {
        let profile = Files(whichroot: .profileRoot, configpath: ViewControllerReference.shared.configpath)
        self.allprofiles = profile.getDirectorysStrings()
    }

    private func checallconfigurations() {
        guard self.allprofiles != nil else { return }
        var configurations: [Configuration]?
        for i in 0 ..< self.allprofiles!.count {
            let profilename = self.allprofiles![i]
            if self.allconfigurations == nil { self.allconfigurations = [] }
            if profilename == "Default profile" {
                configurations = PersistentStorageAPI(profile: nil).getConfigurations()
            } else {
                configurations = PersistentStorageAPI(profile: profilename).getConfigurations()
            }
            if configurations != nil {
                for j in 0 ..< configurations!.count {
                    self.allconfigurations!.append(configurations![j])
                }
            }
        }
    }
    
    init(path: String) {
        self.path = path
        self.getprofilenames()
    }
}
