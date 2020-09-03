//
//  files.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

enum Fileerrortype {
    case openlogfile
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
}

// Protocol for reporting file errors
protocol Fileerror: AnyObject {
    func errormessage(errorstr: String, errortype: Fileerrortype)
}

protocol FileErrors {
    var errorDelegate: Fileerror? { get }
}

extension FileErrors {
    var errorDelegate: Fileerror? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }

    func error(error: String, errortype: Fileerrortype) {
        self.errorDelegate?.errormessage(errorstr: error, errortype: errortype)
    }
}

class Catalogsandfiles: NamesandPaths, FileErrors {
    // Function for returning profiles as array of Strings
    func getcatalogsasstringnames() -> [String]? {
        var array = [String]()
        array.append(NSLocalizedString("Default profile", comment: "default profile"))
        if let atpath = self.fullroot {
            do {
                for folders in try Folder(path: atpath).subfolders {
                    array.append(folders.name)
                }
                return array
            } catch {
                return nil
            }
        }
        return nil
    }

    override init(profileorsshrootpath whichroot: Profileorsshrootpath) {
        super.init(profileorsshrootpath: whichroot)
    }
}
