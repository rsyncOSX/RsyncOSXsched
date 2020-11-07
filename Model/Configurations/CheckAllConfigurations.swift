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

    private func getconfigurations(profile: String?) -> [Configuration]? {
        var configurations = [Configuration]()
        if ViewControllerReference.shared.json {
            let read = PersistentStorageConfigurationJSON(profile: profile, writeonly: false)
            let transform = TransformConfigfromJSON()
            for i in 0 ..< (read.decodedjson?.count ?? 0) {
                if let configitem = read.decodedjson?[i] as? DecodeConfigJSON {
                    let transformed = transform.transform(object: configitem)
                    if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                        configurations.append(transformed)
                    }
                }
            }
        } else {
            let read = PersistentStorageConfiguration(profile: profile, writeonly: false)
            guard read.configurationsasdictionary != nil else { return nil }
            for dict in read.configurationsasdictionary! {
                let conf = Configuration(dictionary: dict)
                configurations.append(conf)
            }
        }
        return configurations
    }

    private func readallconfigurations() {
        guard self.allprofiles != nil else { return }
        var configurations: [Configuration]?
        for i in 0 ..< (self.allprofiles?.count ?? 0) {
            let profile = self.allprofiles![i]
            if self.allconfigurations == nil {
                self.allconfigurations = []
            }
            if profile == NSLocalizedString("Default profile", comment: "default profile") {
                configurations = getconfigurations(profile: nil)
            } else {
                configurations = getconfigurations(profile: profile)
            }
            for j in 0 ..< (configurations?.count ?? 0) {
                configurations?[j].profile = profile
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
