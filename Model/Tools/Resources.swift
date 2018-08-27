//
//  Resources.swift
//  RcloneOSX
//
//  Created by Thomas Evensen on 20/12/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable line_length

import Foundation

// Enumtype type of resource
enum ResourceType {
    case changelog
    case documents
    case urlPlist
}

struct Resources {
    // Resource strings
    private var changelog: String = "https://rsyncosx.github.io/RcloneChangelog"
    private var documents: String = "https://rsyncosx.github.io/RcloneIntro"
    private var urlPlist: String = "https://raw.githubusercontent.com/rsyncOSX/rcloneosx/master/versionRcloneOSX/versionRcloneOSX.plist"
    // Get the resource.
    func getResource (resource: ResourceType) -> String {
        switch resource {
        case .changelog:
            return self.changelog
        case .documents:
            return self.documents
        case .urlPlist:
            return self.urlPlist
        }
    }

}
