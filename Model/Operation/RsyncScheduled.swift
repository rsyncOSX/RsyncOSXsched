//
//  RsyncScheduled.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class RsyncScheduled: ProcessCmd {
    init (arguments: [String]?) {
        super.init(command: nil, arguments: arguments)
    }
}
