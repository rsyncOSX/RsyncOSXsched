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

enum Root {
    case profileRoot
    case sshRoot
}

class Files: Reportfileerror, SetConfigurations {

    var root: Root?
    var rootpath: String?

    private func setrootpath() {
        switch self.root! {
        case .profileRoot:
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let docuDir = (paths.firstObject as? String)!
            let profilePath = docuDir + ViewControllerReference.shared.configpath + Tools().getMacSerialNumber()!
            self.rootpath = profilePath
        case .sshRoot:
            self.rootpath = NSHomeDirectory() + "/.ssh/"
        }
    }

    // Function for returning directorys in path as array of URLs
    func getDirectorysURLs() -> [URL]? {
        var array: [URL]?
        if let filePath = self.rootpath {
            if let fileURLs = self.getfileURLs(path: filePath) {
                array = [URL]()
                for i in 0 ..< fileURLs.count where fileURLs[i].hasDirectoryPath {
                    array!.append(fileURLs[i])
                }
                return array
            }
        }
        return nil
    }

    // Function for returning files in path as array of URLs
    func getFilesURLs() -> [URL]? {
        var array: [URL]?
        if let filePath = self.rootpath {
            let fileManager = FileManager.default
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: filePath, isDirectory: &isDir) {
                guard isDir.boolValue else { return nil }
            } else { return nil }
            if let fileURLs = self.getfileURLs(path: filePath) {
                array = [URL]()
                for i in 0 ..< fileURLs.count where fileURLs[i].isFileURL {
                    array!.append(fileURLs[i])
                }
                return array
            }
        }
        return nil
    }

    // Function for returning files in path as array of Strings
    func getFileStrings() -> [String]? {
        var array: [String]?
        if let filePath = self.rootpath {
            let fileManager = FileManager.default
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: filePath, isDirectory: &isDir) {
                guard isDir.boolValue else { return nil }
            } else { return nil }
            if let fileURLs = self.getfileURLs(path: filePath) {
                array = [String]()
                for i in 0 ..< fileURLs.count where fileURLs[i].isFileURL {
                    array!.append(fileURLs[i].path)
                }
                return array
            }
        }
        return nil
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

    // Check if file exist or not
    func checkFileExist(file: String) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: file) {
            return true
        } else {
            return false
        }
    }

    init (root: Root) {
        self.root = root
        self.setrootpath()
    }

}
