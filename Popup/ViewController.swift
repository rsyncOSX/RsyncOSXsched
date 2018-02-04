//
//  ViewController.swift
//  Popup
//
//  Created by Maxim on 10/21/15.
//  Copyright © 2015 Maxim. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var configurations: Configurations?
    var schedule: Schedules?
    var profile = "RsyncOSXtest"

	override func viewDidLoad() {
		super.viewDidLoad()
        ViewControllerReference.shared.viewControllermain = self
        self.configurations = Configurations(profile: self.profile)
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	@IBAction func closeButtonAction(_ sender: NSButton) {
		NSApp.terminate(self)
	}

}

extension ViewController: ScheduledTaskWorking {
    func start() {
        //
    }
    
    func completed() {
        //
    }
    
    func notifyScheduledTask(config: Configuration?) {
        //
    }

}

extension ViewController: Sendprocessreference {
    func sendprocessreference(process: Process?) {
        //
    }
    
    func sendoutputprocessreference(outputprocess: OutputProcess?) {
        //
    }
    
    
}

