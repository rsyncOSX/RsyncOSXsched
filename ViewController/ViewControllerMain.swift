//
//  ViewController.swift
//  Popup
//
//  Created by Maxim on 10/21/15.
//  Copyright © 2015 Maxim. All rights reserved.
//

import Cocoa
import Foundation


class ViewControllerMain: NSViewController, Coloractivetask, Delay {
    
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var profilescombobox: NSComboBox!
    @IBOutlet weak var profileinfo: NSTextField!
    @IBOutlet weak var rsyncosxbutton: NSButton!
    @IBOutlet weak var statuslight: NSImageView!
    @IBOutlet weak var info: NSTextField!
    
    var configurations: Configurations?
    var schedules: Schedules?
    var sortedandexpanded: ScheduleSortedAndExpand?
    var outputprocess: OutputProcess?
    var profilename: String?
    var tools: Tools?
    
    private var profilesArray: [String]?
    private var profile: Profiles?
    private var useprofile: String?

	override func viewDidLoad() {
		super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        ViewControllerReference.shared.viewControllermain = self
        self.configurations = Configurations(profile: self.profilename)
        self.schedules = Schedules(profile: self.profilename)
        self.sortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstcheduledtask()
        self.tools = Tools()
        self.tools?.testAllremoteserverConnections()
	}
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.setprofiles()
        self.checkforrunning()
        self.info(num: -1)
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
    
    private func checkforrunning() {
        guard Running().rsyncOSXisrunning == false else {
            self.rsyncosxbutton.isEnabled = false
            return
        }
        if ViewControllerReference.shared.pathrsyncosx != nil {
            self.rsyncosxbutton.isEnabled = true
        } else {
            self.rsyncosxbutton.isEnabled = false
        }
    }

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
    
    @IBAction func abort(_ sender: NSButton) {
        ViewControllerReference.shared.process?.terminate()
        self.progress.stopAnimation(nil)
        self.reload()
    }
    
	@IBAction func closeButtonAction(_ sender: NSButton) {
		NSApp.terminate(self)
	}
    
    @IBAction func openRsyncOSX(_ sender: NSButton) {
        let pathtorsyncosxapp: String = ViewControllerReference.shared.pathrsyncosx! + "/" + ViewControllerReference.shared.namersyncosx
        NSWorkspace.shared.open(URL(fileURLWithPath: pathtorsyncosxapp))
        NSApp.terminate(self)
    }

    @IBAction func selectprofile(_ sender: NSComboBox) {
        self.tools = nil
        self.reload()
    }
    
    private func reload() {
        self.info(num: -1)
        guard self.profilesArray != nil else { return }
        guard self.profilescombobox.indexOfSelectedItem > -1 else {
            self.profileinfo.stringValue = "Profile: default"
            self.profilename = nil
            self.createandreloadconfigurations()
            self.createandreloadschedules()
            self.startfirstcheduledtask()
            return
        }
        self.profilename = self.profilesArray![self.profilescombobox.indexOfSelectedItem]
        self.profileinfo.stringValue = "Profile: " + self.profilename!
        self.createandreloadconfigurations()
        self.createandreloadschedules()
        self.startfirstcheduledtask()
        if self.tools == nil {
            self.tools = Tools()
            self.tools?.testAllremoteserverConnections()
        }
    }
    
    func startfirstcheduledtask() {
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        ViewControllerReference.shared.dispatchTaskWaiting = nil
        _ = OperationFactory()
    }
    
    func createandreloadschedules() {
        guard self.configurations != nil else {
            self.schedules = Schedules(profile: nil)
            return
        }
        if let profile = self.profilename {
            self.schedules = nil
            self.schedules = Schedules(profile: profile)
        } else {
            self.schedules = nil
            self.schedules = Schedules(profile: nil)
        }
        self.sortedandexpanded = ScheduleSortedAndExpand()
        self.schedules?.scheduledTasks = self.sortedandexpanded?.firstscheduledtask()
        ViewControllerReference.shared.scheduledTask = self.sortedandexpanded?.firstscheduledtask()
    }
    
    func createandreloadconfigurations() {
        guard self.configurations != nil else {
            self.configurations = Configurations(profile: nil)
            return
        }
        if let profile = self.profilename {
            self.configurations = nil
            self.configurations = Configurations(profile: profile)
        } else {
            self.configurations = nil
            self.configurations = Configurations(profile: nil)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
    
    private func setprofiles() {
        self.profile = nil
        self.profile = Profiles()
        self.profilesArray = self.profile!.getDirectorysStrings()
        self.profilescombobox.removeAllItems()
        guard self.profilesArray != nil else { return }
        self.profilescombobox.addItems(withObjectValues: (self.profilesArray!))
    }
    
    private func info (num: Int) {
        globalMainQueue.async(execute: { () -> Void in
            switch num {
            case 1:
                self.info.stringValue = "One or more remote sites not avaliable...."
            default:
                self.info.stringValue = ""
            }
        })
    }
    
}

extension ViewControllerMain: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configurations?.getConfigurationsDataSourcecountBackup()?.count ?? 0
    }
}

extension ViewControllerMain: NSTableViewDelegate, Attributedestring {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.configurations!.getConfigurationsDataSourcecountBackup()!.count  else { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackup()![row]
        var number: Int?
        var taskintime: String?
        let hiddenID: Int = (object.value(forKey: "hiddenID") as? Int)!
        switch tableColumn!.identifier.rawValue {
        case "numberCellID" :
            if self.sortedandexpanded != nil {
                number = self.sortedandexpanded!.countscheduledtasks(hiddenID).0
            }
            if number ?? 0 > 0 {
                let returnstr = String(number!)
                if let color = self.colorindex, color == hiddenID {
                    return self.attributedstring(str: returnstr, color: NSColor.red, align: .center)
                } else {
                    return returnstr
                }
            }
        case "batchCellID" :
            return object[tableColumn!.identifier] as? Int!
        case "offsiteServerCellID":
            if (object[tableColumn!.identifier] as? String)!.isEmpty {
                return "localhost"
            } else {
                return object[tableColumn!.identifier] as? String
            }
        case "inCellID":
            if self.sortedandexpanded != nil {
                taskintime = self.sortedandexpanded!.sortandcountscheduledonetask(hiddenID)
                return taskintime ?? ""
            }
        default:
            return object[tableColumn!.identifier] as? String
        }
        return nil
    }
}

extension ViewControllerMain: Updatestatuslight {
    func updatestatuslight(color: status) {
        switch color {
        case .red:
            self.statuslight.image = #imageLiteral(resourceName: "red")
        case .green:
            self.statuslight.image = #imageLiteral(resourceName: "green")
        }
    }
}

extension ViewControllerMain: Updatestatustcpconnections {
    func updatestatustcpconnections() {
        self.info(num: 1)
    }
}


