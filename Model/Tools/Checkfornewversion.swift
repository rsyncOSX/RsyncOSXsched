//
//  newVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

protocol RsyncOSXschedversion: class {
    func notifyNewVersion()
    func currentversion(version: String)
}

final class Checkfornewversion {

    private var runningVersion: String?
    private var urlPlist: String?
    private var urlNewVersion: String?

    // External resources
    private var resource: Resources?

    weak var newversionDelegate: RsyncOSXschedversion?

    //If new version set URL for download link and notify caller
    private func urlnewVersion () {
        self.newversionDelegate?.currentversion(version: self.runningVersion ?? "")
        globalBackgroundQueue.async(execute: { () -> Void in
            if let url = URL(string: self.urlPlist!) {
                do {
                    let contents = NSDictionary (contentsOf: url)
                    guard self.runningVersion != nil else { return }
                    if let url = contents?.object(forKey: self.runningVersion!) {
                        self.urlNewVersion = url as? String
                        self.newversionDelegate?.notifyNewVersion()
                        ViewControllerReference.shared.URLnewVersion = self.urlNewVersion
                    }
                }
            }
        })
    }

    // Return version of RsyncOSXsched
    func rsyncOSXschedversion() -> String? {
        return self.runningVersion
    }

    init () {
        let infoPlist = Bundle.main.infoDictionary
        let version = infoPlist?["CFBundleShortVersionString"]
        self.newversionDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        if version != nil {
            self.runningVersion = version as? String
        }
        self.urlPlist = Resources().getResource()
        self.urlnewVersion()
    }

}
