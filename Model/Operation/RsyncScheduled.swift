//
//  RsyncScheduled.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

final class RsyncScheduled: ProcessCmd {
    init (arguments: [String]?, configuration: Configurations?) {
        super.init(command: nil, arguments: arguments, configurations: configuration)
        // self.updateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}
