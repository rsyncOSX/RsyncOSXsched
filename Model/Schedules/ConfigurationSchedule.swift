//
//  ConfigurationSchedule.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 02/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

struct Log {
    var dateExecuted: String?
    var resultExecuted: String?
    var delete: Bool?
}

struct ConfigurationSchedule {
    var hiddenID: Int
    var offsiteserver: String?
    var dateStart: String
    var dateStop: String?
    var schedule: String
    var logrecords: [Log]?
    var delete: Bool?
    var profilename: String?

    init(dictionary: NSDictionary, log: NSArray?, nolog: Bool) {
        self.hiddenID = dictionary.object(forKey: "hiddenID") as? Int ?? -1
        self.dateStart = dictionary.object(forKey: "dateStart") as? String ?? ""
        self.schedule = dictionary.object(forKey: "schedule") as? String ?? ""
        self.offsiteserver = dictionary.object(forKey: "offsiteserver") as? String ?? ""
        if let date = dictionary.object(forKey: "dateStop") as? String { self.dateStop = date }
        if log != nil, nolog == false {
            for i in 0 ..< (log?.count ?? 0) {
                if i == 0 { self.logrecords = [Log]() }
                var logrecord = Log()
                if let dict = log?[i] as? NSDictionary {
                    logrecord.dateExecuted = dict.object(forKey: "dateExecuted") as? String
                    logrecord.resultExecuted = dict.object(forKey: "resultExecuted") as? String
                }
                self.logrecords?.append(logrecord)
            }
        }
    }
}
