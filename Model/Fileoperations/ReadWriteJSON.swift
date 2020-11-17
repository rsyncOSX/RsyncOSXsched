//
//  ReadWriteJSON.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 29/10/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Files
import Foundation

class ReadWriteJSON: NamesandPaths, FileErrors {
    var jsonstring: String?

    func writeJSONToPersistentStore() {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                let folder = try Folder(path: atpath)
                let file = try folder.createFile(named: self.filename ?? "")
                if let data = self.jsonstring {
                    try file.write(data)
                }
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
            }
        }
    }

    func readJSONFromPersistentStore() throws -> String? {
        if var atpath = self.fullroot {
            do {
                if self.profile != nil {
                    atpath += "/" + (self.profile ?? "")
                }
                // check if file exists befor reading, if not bail out
                guard try Folder(path: atpath).containsFile(named: self.filename ?? "") else { return nil }
                let jsonfile = atpath + "/" + (self.filename ?? "")
                let file = try File(path: jsonfile)
                return try file.readAsString()
            } catch let e {
                let error = e as NSError
                self.error(error: error.description, errortype: .json)
                return nil
            }
        }
        return nil
    }

    override init(profile: String?, whattoreadwrite: WhatToReadWrite) {
        super.init(profileorsshrootpath: .profileroot)
        if whattoreadwrite == .configuration {
            self.filename = ViewControllerReference.shared.fileconfigurationsjson
        } else {
            self.filename = ViewControllerReference.shared.fileschedulesjson
        }
        self.profile = profile
    }
}
