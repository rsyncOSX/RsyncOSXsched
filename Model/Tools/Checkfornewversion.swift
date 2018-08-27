//
//  newVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

protocol NewVersionDiscovered: class {
    func notifyNewVersion()
}

final class Checkfornewversion {

    private var runningVersion: String?
    private var urlPlist: String?
    private var urlNewVersion: String?

    // External resources
    private var resource: Resources?

    weak var newversionDelegate: NewVersionDiscovered?

    //If new version set URL for download link and notify caller
    private func urlnewVersion () {
        globalBackgroundQueue.async(execute: { () -> Void in
            if let url = URL(string: self.urlPlist!) {
                do {
                    let contents = NSDictionary (contentsOf: url)
                    guard self.runningVersion != nil else {
                        return
                    }
                    if let url = contents?.object(forKey: self.runningVersion!) {
                        self.urlNewVersion = url as? String
                        self.newversionDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
                        self.newversionDelegate?.notifyNewVersion()
                        ViewControllerReference.shared.URLnewVersion = self.urlNewVersion
                    }
                }
            }
        })
    }

    // Return version of RsyncOSX
    func rsyncOSXversion() -> String? {
        return self.runningVersion
    }

    init () {
        let infoPlist = Bundle.main.infoDictionary
        let version = infoPlist?["CFBundleShortVersionString"]
        if version != nil {
            self.runningVersion = version as? String
        }
        self.resource = Resources()
        if let resource = self.resource {
            self.urlPlist = resource.getResource(resource: .urlPlist)
        }
        self.urlnewVersion()
    }

}
