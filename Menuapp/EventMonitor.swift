//
//  EventMonitor.swift
//  uah
//
//  Created by Maxim on 10/4/15.
//  Copyright © 2015 Maxim Bilan. All rights reserved.
//

import Cocoa

open class EventMonitor {
    private var monitor: AnyObject?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    open func start() {
        self.monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject?
    }

    open func stop() {
        if self.monitor != nil {
            NSEvent.removeMonitor(monitor!)
            self.monitor = nil
        }
    }
}
