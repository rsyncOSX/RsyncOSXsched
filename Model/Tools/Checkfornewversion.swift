//
//  newVersion.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

protocol NewVersionDiscovered: class {
    func notifyNewVersion()
    func currentversion(version: String)
}

final class Checkfornewversion {

    private var runningVersion: String?
    private var urlPlist: String?
    private var urlNewVersion: String?

    weak var newversionDelegate: NewVersionDiscovered?

    //If new version set URL for download link and notify caller
    private func urlnewVersion () {
        self.newversionDelegate?.currentversion(version: self.runningVersion ?? "")
        globalBackgroundQueue.async(execute: { () -> Void in
            if let url = URL(string: self.urlPlist ?? "") {
                do {
                    let contents = NSDictionary (contentsOf: url)
                    if let url = contents?.object(forKey: self.runningVersion ?? "") {
                        self.urlNewVersion = url as? String
                        self.newversionDelegate?.notifyNewVersion()
                        ViewControllerReference.shared.URLnewVersion = self.urlNewVersion
                    }
                }
            }
        })
    }

    init () {
        let infoPlist = Bundle.main.infoDictionary
        if let version = infoPlist?["CFBundleShortVersionString"] {
            self.runningVersion = version as? String
            self.newversionDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
            self.urlPlist = Resources().getResource()
            self.urlnewVersion()
        }
    }
}
