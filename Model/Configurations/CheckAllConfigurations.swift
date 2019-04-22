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

    private func getprofilenames() {
        let profile = Files(whichroot: .profileRoot, configpath: ViewControllerReference.shared.configpath)
        self.allprofiles = profile.getDirectorysStrings()
    }

    private func readallconfigurations() {
        self.getprofilenames()
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

    func check() {
        self.delayWithSeconds(10) {
            guard self.allconfigurations != nil else { return }
            guard self.allpaths != nil else { return }
            for i in 0 ..< self.allpaths!.count {
                let mountedpath = self.allpaths![i]
                for j in 0 ..< self.allconfigurations!.count {
                    let offsitepath = self.allconfigurations![j].offsiteCatalog
                    if offsitepath.contains(mountedpath) && self.allconfigurations![j].offsiteServer.isEmpty {
                        let profile = self.allconfigurations![j].profilename ?? "Default profile"
                        self.logDelegate?.addlog(logrecord: "Found mounted Volume " + mountedpath + " in: " + profile)
                    }
                }
            }
        }
    }

    init(path: String) {
        self.allpaths = [String]()
        self.allpaths?.append(path)
        self.readallconfigurations()
        self.check()
    }
}
