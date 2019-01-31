//
//  AppDelegate.swift
//  Popup
//  swiftlint:disable line_length

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	let popover = NSPopover()
	var eventMonitor: EventMonitor?

    var storyboard: NSStoryboard? {
        return NSStoryboard(name: "Main", bundle: nil)
    }

    var mainViewController: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "ViewControllerId")
            as? NSViewController)!
    }

	func applicationDidFinishLaunching(_ aNotification: Notification) {
        var storage: PersistentStorageAPI?
        // Read user configuration
        storage = PersistentStorageAPI(profile: nil)
        if let userConfiguration =  storage?.getUserconfiguration(readfromstorage: true) {
            _ = Userconfiguration(userconfigRsyncOSX: userConfiguration)
        }
		if let button = self.statusItem.button {
			button.image = NSImage(named: "MenubarButton")
			button.action = #selector(AppDelegate.togglePopover(_:))
		}
		self.popover.contentViewController = self.mainViewController
		self.eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { [weak self] event in
			if let popover = self?.popover {
				if popover.isShown {
					self?.closePopover(event)
				}
			}
		}
		self.eventMonitor?.start()
        self.togglePopover(nil)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}

	@objc func togglePopover(_ sender: AnyObject?) {
		if self.popover.isShown {
			self.closePopover(sender)
		} else {
			self.showPopover(sender)
		}
	}

	func showPopover(_ sender: AnyObject?) {
		if let button = self.statusItem.button {
			self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
			self.eventMonitor?.start()
		}
	}

	func closePopover(_ sender: AnyObject?) {
		self.popover.performClose(sender)
		self.eventMonitor?.stop()
	}
}
