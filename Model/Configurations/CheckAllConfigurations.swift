//
//  CheckAllConfigurations.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 19/04/2019.
//  Copyright © 2019 Maxim. All rights reserved.
//
// swiftlint:disable line_length trailing_comma

import Foundation

protocol Startautomaticexecution: AnyObject {
    func startautomaticexecution()
}

class CheckAllConfigurations: Delay, Setlog {
    var allprofiles: [String]?
    var allconfigurations: [Configuration]?
    var allpaths: [String]?
    var listofautomaticexecutions: [NSDictionary]?
    weak var startautomaticexecution: Startautomaticexecution?

    private func getprofilenames() {
        let profile = Files(profileorsshrootpath: .profileroot)
        self.allprofiles = profile.getDirectorysStrings()
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

    func checkforautomaticexecution() {
        self.delayWithSeconds(10) {
            for i in 0 ..< (self.allpaths?.count ?? 0) {
                if let mountedpath = self.allpaths?[i] {
                    for j in 0 ..< (self.allconfigurations?.count ?? 0) {
                        let offsitepath = self.allconfigurations![j].offsiteCatalog
                        if offsitepath.contains(mountedpath), self.allconfigurations![j].offsiteServer.isEmpty {
                            let profile = self.allconfigurations![j].profilename ?? NSLocalizedString("Default profile", comment: "default profile")
                            let mountedvolume: String = NSLocalizedString("Mounted Volume discovered", comment: "Mount")
                            let mountedvolumein: String = NSLocalizedString("in:", comment: "Mount")
                            self.logDelegate?.addlog(logrecord: mountedvolume + mountedpath + " " + mountedvolumein + " " + profile)
                            if self.listofautomaticexecutions == nil { self.listofautomaticexecutions = [NSDictionary]() }
                            let dict: NSDictionary = [
                                "profilename": self.allconfigurations![j].profilename!,
                                "hiddenID": self.allconfigurations![j].hiddenID,
                            ]
                            self.listofautomaticexecutions?.append(dict)
                        }
                    }
                }
                // Kick off automatic backup
                self.startautomaticexecution = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
                self.startautomaticexecution?.startautomaticexecution()
            }
        }
    }

    init(path: String) {
        self.allpaths = [String]()
        self.allpaths?.append(path)
        self.readallconfigurations()
        self.checkforautomaticexecution()
    }
}
