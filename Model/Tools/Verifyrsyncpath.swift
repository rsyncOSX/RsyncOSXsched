//
//  Verifyrsyncpath.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.07.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class Verifyrsyncpath: SetConfigurations {

    // Function returns the correct path for rsync according to configuration set by user or
    func rsyncpath() -> String {
        if ViewControllerReference.shared.rsyncVer3 {
            if ViewControllerReference.shared.rsyncPath == nil {
                return ViewControllerReference.shared.usrlocalbinrsync
            } else {
                return ViewControllerReference.shared.rsyncPath! + ViewControllerReference.shared.rsync
            }
        } else {
            return ViewControllerReference.shared.usrbinrsync
        }
    }

    init() {
    }
}
