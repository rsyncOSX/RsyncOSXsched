//
//  ViewControllerInformation.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerLog: NSViewController, SetDismisser, GetInformation {
    @IBOutlet var detailsTable: NSTableView!
    @IBOutlet var writeloggbutton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailsTable.delegate = self
        self.detailsTable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        globalMainQueue.async { () -> Void in
            self.detailsTable.reloadData()
        }
    }

    @IBAction func close(_: NSButton) {
        self.dismissview(viewcontroller: self)
    }

    @IBAction func writelogg(_: NSButton) {
        _ = Logg(array: self.getinfo())
        self.dismissview(viewcontroller: self)
    }
}

extension ViewControllerLog: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.getinfo().count
    }
}

extension ViewControllerLog: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = self.getinfo()[row]
            return cell
        } else {
            return nil
        }
    }
}
