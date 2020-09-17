//
//  extensionRsyncParameters.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 01/08/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

extension RsyncParameters {
    // Function for initialize arguments array.
    func argumentsRsync(config: Configuration) -> [String]? {
        self.localCatalog = config.localCatalog
        if config.task == ViewControllerReference.shared.syncremote {
            self.remoteargssyncremote(config: config)
        } else {
            self.remoteargs(config: config)
        }
        self.setParameters1To6(config: config, dryRun: false, forDisplay: false, verify: false)
        self.setParameters8To14(config: config, dryRun: false, forDisplay: false)
        switch config.task {
        case ViewControllerReference.shared.synchronize:
            self.argumentsforsynchronize(dryRun: false, forDisplay: false)
        case ViewControllerReference.shared.snapshot:
            self.linkdestparameter(config: config, verify: false)
            self.argumentsforsynchronizesnapshot(dryRun: false, forDisplay: false)
        case ViewControllerReference.shared.syncremote:
            self.argumentsforsynchronizeremote(dryRun: false, forDisplay: false)
        default:
            break
        }
        return self.arguments
    }
}
