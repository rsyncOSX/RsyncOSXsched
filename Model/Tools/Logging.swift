//
//  Logging.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 17.02.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

class Logging: Reportfileerror {

    var array: [String]?
    var log: String?
    var filename: String?
    var fileURL: URL?

    private func write() {
        do {
            try self.log!.write(to: self.fileURL!, atomically: true, encoding: String.Encoding.utf8)
        } catch let e {
            let error = e as NSError
            self.error(error: error.description, errortype: .writelogfile)
        }
    }

    private func read() {
        do {
            self.log = try String(contentsOf: self.fileURL!, encoding: String.Encoding.utf8)
        } catch let e {
            let error = e as NSError
            self.error(error: error.description, errortype: .openlogfile)
        }
    }

    private func logg() {
        let currendate = Date()
        let dateformatter = Tools().setDateformat()
        let date = dateformatter.string(from: currendate)
        self.read()
        let tmplogg: String = "\n" + "-------------------------------------------\n" + date + "\n"
            + "-------------------------------------------\n"
        if self.log == nil {
            self.log = tmplogg + (self.array?.joined(separator: "\n"))!
        } else {
            self.log = self.log! + tmplogg  + (self.array?.joined(separator: "\n"))!
        }
        self.write()
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    init(array: [String]) {
        self.array = array
        self.filename = ViewControllerReference.shared.logname
        let DocumentDirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        self.fileURL = DocumentDirURL?.appendingPathComponent(self.filename!).appendingPathExtension("txt")
        ViewControllerReference.shared.fileURL = self.fileURL
        self.logg()
    }
}
