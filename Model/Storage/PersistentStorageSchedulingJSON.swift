//
//  PersistentStorageSchedulingJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

class PersistentStorageSchedulingJSON: ReadWriteJSON, SetSchedules {
    // var schedules: [ConfigurationSchedule]?
    var decodedjson: [Any]?

    // Saving Schedules from MEMORY to persistent store
    func savescheduleInMemoryToPersistentStore() {
        if let schedules: [ConfigurationSchedule] = ConvertSchedules(JSON: true).cleanedschedules {
            self.writeToStore(schedules: schedules)
        }
    }

    // Writing schedules to persistent store
    private func writeToStore(schedules: [ConfigurationSchedule]?) {
        self.createJSONfromstructs(schedules: schedules)
        self.writeJSONToPersistentStore()
    }

    private func createJSONfromstructs(schedules: [ConfigurationSchedule]?) {
        var structscodable: [CodableConfigurationSchedule]?
        if schedules == nil {
            if let schedules = self.schedules?.getSchedule() {
                structscodable = [CodableConfigurationSchedule]()
                for i in 0 ..< schedules.count {
                    structscodable?.append(CodableConfigurationSchedule(schedule: schedules[i]))
                }
            }
        } else {
            if let schedules = schedules {
                structscodable = [CodableConfigurationSchedule]()
                for i in 0 ..< schedules.count {
                    structscodable?.append(CodableConfigurationSchedule(schedule: schedules[i]))
                }
            }
        }
        self.jsonstring = self.encodedata(data: structscodable)
    }

    private func encodedata(data: [CodableConfigurationSchedule]?) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(data)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch let e {
            let error = e as NSError
            self.error(error: error.description, errortype: .json)
            return nil
        }
        return nil
    }

    private func decode(jsonfileasstring: String) {
        if let jsonstring = jsonfileasstring.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                self.decodedjson = try decoder.decode([DecodeScheduleJSON].self, from: jsonstring)
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
            super.init(profile: nil, whattoreadwrite: .schedule)
        } else {
            super.init(profile: profile, whattoreadwrite: .schedule)
        }
        self.profile = profile
        if writeonly == false {
            self.JSONFromPersistentStore()
        }
    }
}
