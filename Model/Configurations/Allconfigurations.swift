//
//  Allconfigurations.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 05.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

import Foundation

class Allconfigurations {
    // Configurations object
    private var allconfigurations: [Configuration]?
    var allconfigurationsasdictionary: [NSMutableDictionary]?
    private var allprofiles: [String]?

    private func getprofilenames() {
        let profilename = Files(root: .profileRoot)
        self.allprofiles = profilename.getDirectorysStrings()
        guard self.allprofiles != nil else { return }
        self.allprofiles!.append("Default profile")
    }

    private func readallconfigurations() {
        guard self.allprofiles != nil else { return }
        var configurations: [Configuration]?
        for i in 0 ..< self.allprofiles!.count {
            let profilename = self.allprofiles![i]
            if self.allconfigurations == nil {
                self.allconfigurations = []
            }
            if profilename == "Default profile" {
                configurations = PersistentStorageAPI(profile: nil).getConfigurations()
            } else {
                configurations = PersistentStorageAPI(profile: profilename).getConfigurations()
            }
            guard configurations != nil else { return }
            for j in 0 ..< configurations!.count {
                configurations![j].profile = profilename
                self.allconfigurations!.append(configurations![j])
            }
        }
    }

    private func setConfigurationsDataSourcecountBackupSnapshot() {
        guard self.allconfigurations != nil else { return }
        var configurations: [Configuration] = self.allconfigurations!.filter({return ($0.task == "backup" || $0.task == "snapshot" )})
        var data = [NSMutableDictionary]()
        for i in 0 ..< configurations.count {
            if configurations[i].offsiteServer.isEmpty == true {
                configurations[i].offsiteServer = "localhost"
            }
            let row: NSMutableDictionary = [
                "profilename": configurations[i].profile ?? "",
                "task": configurations[i].task,
                "hiddenID": configurations[i].hiddenID,
                "localCatalog": configurations[i].localCatalog,
                "offsiteCatalog": configurations[i].offsiteCatalog,
                "offsiteServer": configurations[i].offsiteServer,
                "backupID": configurations[i].backupID,
                "dateExecuted": configurations[i].dateRun!,
                "days": configurations[i].dayssincelastbackup ?? "",
                "markdays": configurations[i].markdays,
                "selectCellID": 0
            ]
            data.append(row)
        }
        self.allconfigurationsasdictionary = data
    }

    init() {
        self.getprofilenames()
        self.readallconfigurations()
        self.setConfigurationsDataSourcecountBackupSnapshot()
    }
}
