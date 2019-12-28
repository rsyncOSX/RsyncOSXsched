//
//  Fileerrors.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 21.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum Fileerrortype {
    case openlogfile
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
}

// Protocol for reporting file errors
protocol Fileerror: AnyObject {
    func fileerror(errorstr: String, errortype: Fileerrortype)
}

protocol Reportfileerror {
    var errorDelegate: Fileerror? { get }
}

extension Reportfileerror {
    var errorDelegate: Fileerror? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }

    func error(error: String, errortype: Fileerrortype) {
        self.errorDelegate?.fileerror(errorstr: error, errortype: errortype)
    }
}
