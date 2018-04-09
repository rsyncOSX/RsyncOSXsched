//
//  OperationFactory.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

enum OperationObject {
    case timer
    case dispatch
}

class OperationFactory {

    var operationTimer: ScheduleOperationTimer?
    var operationDispatch: ScheduleOperationDispatch?

    init(factory: OperationObject) {
        switch factory {
        case .timer:
            self.operationTimer = ScheduleOperationTimer()
        case .dispatch:
            self.operationDispatch = ScheduleOperationDispatch()
        }
    }
}
