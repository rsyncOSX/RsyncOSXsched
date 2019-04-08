//
//  ArgumentsOneConfiguration.swift
//
//  Created by Thomas Evensen on 09/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Struct for to store info for ONE configuration.
// Struct is storing rsync arguments for real run, dryrun
// and a version to show in view of both

struct ArgumentsOneConfiguration {

    var config: Configuration?
    var arg: [String]?

    init(config: Configuration) {
        self.config = config
        self.arg = RsyncParametersProcess().argumentsRsync(config, dryRun: false)
    }
}
