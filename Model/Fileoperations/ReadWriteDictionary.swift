//
//  Readwritefiles.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  let str = "/Rsync/" + serialNumber + profile? + "/scheduleRsync.plist"
//  let str = "/Rsync/" + serialNumber + profile? + "/configRsync.plist"
//  let str = "/Rsync/" + serialNumber + "/config.plist"
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

enum WhatToReadWrite {
    case schedule
    case configuration
    case userconfig
    case none
}

class ReadWriteDictionary: SetConfigurations, Setlog {

    // Name set for schedule, configuration or config
    private var name: String?
    // key in objectForKey, e.g key for reading what
    private var key: String?
    // Which profile to read
    var profile: String?
    // If to use profile, only configurations and schedules to read from profile
    private var useProfile: Bool = false
    // task to do
    private var task: WhatToReadWrite?
    // Path for configuration files
    private var filepath: String?
    // Set which file to read
    private var filename: String?

    private func setnameandpath() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let docuDir = (paths.firstObject as? String)!
        if ViewControllerReference.shared.macserialnumber == nil {
            ViewControllerReference.shared.macserialnumber = Macserialnumber().getMacSerialNumber() ?? ""
        }
        let macserialnumber = ViewControllerReference.shared.macserialnumber
        if self.useProfile {
            if let profile = self.profile {
                guard profile.isEmpty == false else { return }
                self.filepath = ViewControllerReference.shared.configpath + macserialnumber! + "/" + profile + "/"
                self.filename = docuDir + ViewControllerReference.shared.configpath + macserialnumber! + "/" + profile + self.name!
            } else {
                // If profile not set use no profile
                self.filename = docuDir +  ViewControllerReference.shared.configpath + macserialnumber! + self.name!
            }
        } else {
            // no profile
            self.filename = docuDir + ViewControllerReference.shared.configpath + macserialnumber! + self.name!
            self.filepath = ViewControllerReference.shared.configpath + macserialnumber! + "/"
        }
    }

    // Function for reading data from persistent store
    func readNSDictionaryFromPersistentStore() -> [NSDictionary]? {
        var data = [NSDictionary]()
        guard self.filename != nil && self.key != nil else { return nil }
        let dictionary = NSDictionary(contentsOfFile: self.filename!)
        let items: Any? = dictionary?.object(forKey: self.key!)
        guard items != nil else { return nil }
        if let arrayofitems = items as? NSArray {
            for i in 0 ..< arrayofitems.count {
                if let item = arrayofitems[i] as? NSDictionary {
                    data.append(item)
                }
            }
        }
        return data
    }

    // Function for write data to persistent store
    func writeNSDictionaryToPersistentStorage (_ array: [NSDictionary]) -> Bool {
        let dictionary = NSDictionary(object: array, forKey: self.key! as NSCopying)
        guard self.filename != nil else { return false }
        self.logDelegate?.addlog(logrecord: "Writing: " + self.filename! + " to disk.")
        return  dictionary.write(toFile: self.filename!, atomically: true)
    }

    // Set preferences for which data to read or write
    private func setpreferences (_ task: WhatToReadWrite) {
        self.task = task
        switch self.task! {
        case .schedule:
            self.name = "/scheduleRsync.plist"
            self.key = "Schedule"
        case .configuration:
            self.name = "/configRsync.plist"
            self.key = "Catalogs"
        case .userconfig:
            self.name = "/config.plist"
            self.key = "config"
        case .none:
            self.name = nil
        }
    }

    init(whattoreadwrite: WhatToReadWrite, profile: String?) {
        if profile != nil {
            self.profile = profile
            self.useProfile = true
        }
        self.setpreferences(whattoreadwrite)
        self.setnameandpath()
    }

}
