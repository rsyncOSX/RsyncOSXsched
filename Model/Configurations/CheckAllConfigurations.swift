//
//  CheckAllConfigurations.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 19/04/2019.
//  Copyright © 2019 Maxim. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

protocol Startautomaticexecution: class {
    func startautomaticexecution()
}

class CheckAllConfigurations: Delay, Setlog {
    var allprofiles: [String]?
    var allconfigurations: [Configuration]?
    var allpaths: [String]?
    var automaticexecution: [NSDictionary]?
    weak var start: Startautomaticexecution?

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
            if profilename == NSLocalizedString("Default profile", comment: "default profile") {
                configurations = PersistentStorageConfiguration(profile: nil).getConfigurations()
            } else {
                configurations = PersistentStorageConfiguration(profile: profilename).getConfigurations()
            }
            if configurations != nil {
                for j in 0 ..< configurations!.count {
                    configurations![j].profilename = profilename
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
                    if offsitepath.contains(mountedpath), self.allconfigurations![j].offsiteServer.isEmpty {
                        let profile = self.allconfigurations![j].profilename ?? NSLocalizedString("Default profile", comment: "default profile")
                        let mountedvolume: String = NSLocalizedString("Mounted Volume discovered", comment: "Mount")
                        let mountedvolumein: String = NSLocalizedString("in:", comment: "Mount")
                        self.logDelegate?.addlog(logrecord: mountedvolume + mountedpath + " " + mountedvolumein + " " + profile)

                        if self.automaticexecution == nil { self.automaticexecution = [NSDictionary]() }
                        let dict: NSDictionary = [
                            "profilename": self.allconfigurations![j].profilename!,
                            "hiddenID": self.allconfigurations![j].hiddenID,
                        ]
                        self.automaticexecution?.append(dict)
                    }
                }
            }
            // Kick off automatic backup
            self.start?.startautomaticexecution()
        }
    }

    init(path: String) {
        self.allpaths = [String]()
        self.allpaths?.append(path)
        self.readallconfigurations()
        self.start = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        self.check()
    }
}
