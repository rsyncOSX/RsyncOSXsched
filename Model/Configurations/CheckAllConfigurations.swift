//
//  CheckAllConfigurations.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 19/04/2019.
//  Copyright © 2019 Maxim. All rights reserved.
//

import Foundation

class CheckAllConfigurations: Delay, Setlog {
    var allprofiles: [String]?
    var allconfigurations: [Configuration]?
    var allpaths: [String]?
    var listofautomaticexecutions: [NSDictionary]?

    private func getprofilenames() {
        let profile = Catalogsandfiles(profileorsshrootpath: .profileroot)
        self.allprofiles = profile.getcatalogsasstringnames()
    }

    private func readallconfigurations() {
        self.getprofilenames()
        var configurations: [Configuration]?
        for i in 0 ..< (self.allprofiles?.count ?? 0) {
            let profilename = self.allprofiles?[i]
            if self.allconfigurations == nil { self.allconfigurations = [] }
            if profilename == NSLocalizedString("Default profile", comment: "default profile") {
                configurations = PersistentStorageConfiguration(profile: nil).readconfigurations()
            } else {
                configurations = PersistentStorageConfiguration(profile: profilename).readconfigurations()
            }
            for j in 0 ..< (configurations?.count ?? 0) {
                configurations?[j].profilename = profilename
                self.allconfigurations?.append(configurations![j])
            }
        }
    }

    init(path: String) {
        self.allpaths = [String]()
        self.allpaths?.append(path)
        self.readallconfigurations()
    }
}
