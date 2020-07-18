//
//  InterruptProcess.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 18/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct InterruptProcess {
    init() {
        guard ViewControllerReference.shared.process != nil else { return }
        _ = Logg(array: ["Interrupted] :"])
        ViewControllerReference.shared.process = nil
    }
}
