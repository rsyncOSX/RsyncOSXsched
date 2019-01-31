//
//  files.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

enum Fileerrortype {
    case openlogfile
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
}

// Protocol for reporting file errors
protocol Fileerror: class {
    func fileerror(errorstr: String, errortype: Fileerrortype)
}

protocol Reportfileerror {
    var errorDelegate: Fileerror? { get }
}

extension Reportfileerror {
    weak var errorDelegate: Fileerror? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }

    func error(error: String, errortype: Fileerrortype) {
        self.errorDelegate?.fileerror(errorstr: error, errortype: errortype)
    }
}

enum WhichRoot {
    case profileRoot
    case sshRoot
}

class Files: Reportfileerror, SetConfigurations {

    var whichroot: WhichRoot?
    var rootpath: String?

    private func setrootpath() {
        switch self.whichroot! {
        case .profileRoot:
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let docuDir = (paths.firstObject as? String)!
            let profilePath = docuDir + ViewControllerReference.shared.configpath + Macserialnumber().getMacSerialNumber()!
            self.rootpath = profilePath
        case .sshRoot:
            self.rootpath = NSHomeDirectory() + "/.ssh/"
        }
    }

    // Function for returning profiles as array of Strings
    func getDirectorysStrings() -> [String] {
        var array = [String]()
        array.append("Default profile")
        if let filePath = self.rootpath {
            if let fileURLs = self.getfileURLs(path: filePath) {
                for i in 0 ..< fileURLs.count where fileURLs[i].hasDirectoryPath {
                    let path = fileURLs[i].pathComponents
                    let i = path.count
                    array.append(path[i-1])
                }
                return array
            }
        }
        return array
    }

    // Function for getting fileURLs for a given path
    func getfileURLs (path: String) -> [URL]? {
        let fileManager = FileManager.default
        if let filepath = URL.init(string: path) {
            do {
                let files = try fileManager.contentsOfDirectory(at: filepath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                return files
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .profilecreatedirectory)
                return nil
            }
        } else {
            return nil
        }
    }

    init (whichroot: WhichRoot) {
        self.whichroot = whichroot
        self.setrootpath()
    }

}
