//
//  ConfigurationsData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 15/11/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

final class ConfigurationsData {
    // The main structure storing all Configurations for tasks
    var configurations: [Configuration]?
    var profile: String?
    // Datasource for NSTableViews
    var configurationsDataSource: [NSMutableDictionary]?
    // valid hiddenIDs
    var validhiddenID: Set<Int>?

    func readconfigurationsplist() {
        let store = PersistentStorageConfiguration(profile: self.profile, writeonly: false).configurationsasdictionary
        for i in 0 ..< (store?.count ?? 0) {
            if let dict = store?[i] {
                var config = Configuration(dictionary: dict)
                config.profile = self.profile
                if ViewControllerReference.shared.synctasks.contains(config.task) {
                    if self.validhiddenID?.contains(config.hiddenID) == false {
                        self.configurations?.append(config)
                        self.validhiddenID?.insert(config.hiddenID)
                    }
                }
            }
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var data = [NSMutableDictionary]()
        for i in 0 ..< (self.configurations?.count ?? 0) {
            let task = self.configurations?[i].task
            if ViewControllerReference.shared.synctasks.contains(task ?? "") {
                if let config = self.configurations?[i] {
                    data.append(ConvertOneConfig(config: config).dict)
                }
            }
        }
        self.configurationsDataSource = data
    }

    func readconfigurationsjson() {
        let store = PersistentStorageConfigurationJSON(profile: self.profile, writeonly: false).decodedjson
        let transform = TransformConfigfromJSON()
        for i in 0 ..< (store?.count ?? 0) {
            if let configitem = store?[i] as? DecodeConfiguration {
                let transformed = transform.transform(object: configitem)
                if ViewControllerReference.shared.synctasks.contains(transformed.task) {
                    if self.validhiddenID?.contains(transformed.hiddenID) == false {
                        self.configurations?.append(transformed)
                        self.validhiddenID?.insert(transformed.hiddenID)
                    }
                }
            }
        }
        // Then prepare the datasource for use in tableviews as Dictionarys
        var data = [NSMutableDictionary]()
        for i in 0 ..< (self.configurations?.count ?? 0) {
            let task = self.configurations?[i].task
            if ViewControllerReference.shared.synctasks.contains(task ?? "") {
                if let config = self.configurations?[i] {
                    data.append(ConvertOneConfig(config: config).dict)
                }
            }
        }
        self.configurationsDataSource = data
    }

    init(profile: String?) {
        self.profile = profile
        self.configurationsDataSource = nil
        self.configurations = nil
        self.configurations = [Configuration]()
        self.validhiddenID = Set()
        if ViewControllerReference.shared.json {
            self.readconfigurationsjson()
        } else {
            self.readconfigurationsplist()
        }
    }
}
