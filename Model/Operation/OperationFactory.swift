//
//  OperationFactory.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class OperationFactory {

    var operationDispatch: ScheduleOperationDispatch?

    init() {
        self.operationDispatch = ScheduleOperationDispatch()
    }

}
