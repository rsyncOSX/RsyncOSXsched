//
//  PersistentStorageConfigurationJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

class PersistentStorageConfigurationJSON: ReadWriteJSON, SetConfigurations {
    var decodedjson: [Any]?

    // Saving Configuration from MEMORY to persistent store
    // Reads Configurations from MEMORY and saves to persistent Store
    func saveconfigInMemoryToPersistentStore() {
        if let configurations = self.configurations?.getConfigurations() {
            self.writeToStore(configurations: configurations)
        }
    }

    private func writeToStore(configurations _: [Configuration]?) {
        self.createJSONfromstructs()
        self.writeJSONToPersistentStore()
    }

    private func createJSONfromstructs() {
        var structscodable: [ConvertOneConfigCodable]?
        if let configurations = self.configurations?.getConfigurations() {
            structscodable = [ConvertOneConfigCodable]()
            for i in 0 ..< configurations.count {
                structscodable?.append(ConvertOneConfigCodable(config: configurations[i]))
            }
        }
        self.jsonstring = self.encodedata(data: structscodable)
    }

    private func encodedata(data: [ConvertOneConfigCodable]?) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            return nil
        }
        return nil
    }

    private func decode(jsonfileasstring: String) {
        if let jsonstring = jsonfileasstring.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                self.decodedjson = try decoder.decode([DecodeConfigJSON].self, from: jsonstring)
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    func JSONFromPersistentStore() {
        do {
            if let jsonfile = try self.readJSONFromPersistentStore() {
                guard jsonfile.isEmpty == false else { return }
                self.decode(jsonfileasstring: jsonfile)
            }
        } catch {}
    }

    init(profile: String?, writeonly: Bool) {
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            super.init(profile: nil, filename: ViewControllerReference.shared.fileconfigurationsjson)
        } else {
            super.init(profile: profile, filename: ViewControllerReference.shared.fileconfigurationsjson)
        }
        self.profile = profile
        if writeonly == false {
            self.JSONFromPersistentStore()
        }
    }
}