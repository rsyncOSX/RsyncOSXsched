//
//  ConvertOneConfig.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 25/05/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Foundation

struct ConvertOneConfig {
    var config: Configuration?
    var profile: String?

    var dict: NSDictionary {
        let row: NSDictionary = [
            "profilename": self.profile ?? NSLocalizedString("Default profile", comment: "default profile"),
            "taskCellID": self.config!.task,
            "batchCellID": self.config!.batch,
            "hiddenID": self.config!.hiddenID,
            "localCatalogCellID": self.config!.localCatalog,
            "offsiteCatalogCellID": self.config!.offsiteCatalog,
            "offsiteServerCellID": self.config!.offsiteServer,
            "backupIDCellID": self.config!.backupID,
            "runDateCellID": self.config!.dateRun!,
            "daysID": self.config!.dayssincelastbackup ?? "",
            "markdays": self.config!.markdays,
            "snapCellID": self.config!.snapshotnum ?? "",
            "selectCellID": 0,
        ]
        return row
    }

    init(config: Configuration, profile: String?) {
        self.config = config
        self.profile = profile
    }
}
