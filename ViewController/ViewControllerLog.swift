//
//  ViewControllerInformation.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerLog: NSViewController, SetDismisser, GetInformation {

    @IBOutlet weak var detailsTable: NSTableView!
    @IBOutlet weak var writeloggbutton: NSButton!

    var log: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTable.delegate = self
        detailsTable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.log = self.getinfo()
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self)
    }

    @IBAction func writelogg(_ sender: NSButton) {
        _ = Logging(array: self.log ?? [])
        self.dismissview(viewcontroller: self)
    }
}

extension ViewControllerLog: NSTableViewDataSource {

    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.log?.count ?? 0
    }
}

extension ViewControllerLog: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if tableColumn == tableView.tableColumns[0] {
            text = self.log![row]
            cellIdentifier = "outputID"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
