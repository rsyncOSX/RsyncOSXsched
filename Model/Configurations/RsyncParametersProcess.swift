//
//  rsyncProcessArguments.swift
//  Rsync
//
//  Created by Thomas Evensen on 08/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class RsyncParametersProcess {

    private var stats: Bool?
    private var arguments: [String]?
    var localCatalog: String?
    var offsiteCatalog: String?
    var offsiteUsername: String?
    var offsiteServer: String?
    var remoteargs: String?
    var linkdestparam: String?
    private let suffixString = "--suffix=_`date +'%Y-%m-%d.%H.%M'`"
    private let suffixString2 = "--suffix=_$(date +%Y-%m-%d.%H.%M)"

    private func setParameters1To6(_ config: Configuration) {
        let parameter1: String = config.parameter1
        let parameter2: String = config.parameter2
        let parameter3: String = config.parameter3
        let parameter4: String = config.parameter4
        let parameter5: String = config.parameter5
        let offsiteServer: String = config.offsiteServer
        self.arguments!.append(parameter1)
        self.arguments!.append(parameter2)
        if offsiteServer.isEmpty  == false {
            if parameter3.isEmpty == false {
                self.arguments!.append(parameter3)
            }
        }
        self.arguments!.append(parameter4)
        if offsiteServer.isEmpty {
            // nothing
        } else {
            if parameter5.isEmpty == false {
                self.sshportparameter(config)
            }
        }
    }

    private func sshportparameter(_ config: Configuration) {
        let parameter5: String = config.parameter5
        let parameter6: String = config.parameter6
        // -e
        self.arguments!.append(parameter5)
        if let sshport = config.sshport {
            // "ssh -p xxx"
            self.arguments!.append("ssh -p " + String(sshport))
        } else {
            // ssh
            self.arguments!.append(parameter6)
        }
    }

    // Compute user selected parameters parameter8 ... parameter14
    // Brute force, check every parameter, not special elegant, but it works

    private func setParameters8To14(_ config: Configuration) {
        self.stats = false
        if config.parameter8 != nil {
            self.appendParameter(parameter: config.parameter8!)
        }
        if config.parameter9 != nil {
            self.appendParameter(parameter: config.parameter9!)
        }
        if config.parameter10 != nil {
            self.appendParameter(parameter: config.parameter10!)
        }
        if config.parameter11 != nil {
            self.appendParameter(parameter: config.parameter11!)
        }
        if config.parameter12 != nil {
            self.appendParameter(parameter: config.parameter12!)
        }
        if config.parameter13 != nil {
            self.appendParameter(parameter: config.parameter13!)
        }
        if config.parameter14 != nil {
            if config.offsiteServer.isEmpty == true {
                if config.parameter14! == self.suffixString || config.parameter14! == self.suffixString2 {
                    self.appendParameter(parameter: self.setdatesuffixlocalhost())
                }
            } else {
                self.appendParameter(parameter: config.parameter14!)
            }
        }
        if self.stats == false {
            self.appendParameter(parameter: "--stats")
        }
    }

    private func setdatesuffixlocalhost() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "-yyyy-MM-dd"
        return  "--suffix=" + formatter.string(from: Date())
    }

    // Check userselected parameter and append it to arguments array passed to rsync or displayed
    // on screen.
    private func appendParameter (parameter: String) {
        if parameter.count > 1 {
            if parameter == "--stats" {
                self.stats = true
            }
            self.arguments!.append(parameter)
        }
    }

    // Function for initialize arguments array.
    func argumentsRsync(_ config: Configuration) -> [String] {
        self.localCatalog = config.localCatalog
        self.remoteargs(config)
        self.setParameters1To6(config)
        self.setParameters8To14(config)
        switch config.task {
        case ViewControllerReference.shared.synchronize:
            self.argumentsforsynchronize()
        case ViewControllerReference.shared.snapshot:
            self.linkdestparameter(config, verify: false)
            self.argumentsforsynchronizesnapshot()
        default:
            break
        }
        return self.arguments!
    }

    private func remoteargs(_ config: Configuration) {
        self.offsiteCatalog = config.offsiteCatalog
        self.offsiteUsername = config.offsiteUsername
        self.offsiteServer = config.offsiteServer
        if self.offsiteServer!.isEmpty == false {
            if config.rsyncdaemon != nil {
                if config.rsyncdaemon == 1 {
                    self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + "::" + self.offsiteCatalog!
                } else {
                    self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + ":" + self.offsiteCatalog!
                }
            } else {
                self.remoteargs = self.offsiteUsername! + "@" + self.offsiteServer! + ":" + self.offsiteCatalog!
            }
        }
    }

    // Additional parameters if snapshot
    private func linkdestparameter(_ config: Configuration, verify: Bool) {
        let snapshotnum = config.snapshotnum ?? 1
        self.linkdestparam =  "--link-dest=" + config.offsiteCatalog + String(snapshotnum - 1)
        if self.remoteargs != nil {
            if verify {
                self.remoteargs! += String(snapshotnum - 1)
            } else {
                self.remoteargs! += String(snapshotnum)
            }
        }
        if verify {
            self.offsiteCatalog! += String(snapshotnum - 1)
        } else {
            self.offsiteCatalog! += String(snapshotnum)
        }
    }

    private func argumentsforsynchronize() {
        self.arguments!.append(self.localCatalog!)
        guard self.offsiteCatalog != nil else { return }
        if self.offsiteServer!.isEmpty {
            self.arguments!.append(self.offsiteCatalog!)
        } else {
            self.arguments!.append(remoteargs!)
        }
    }

    private func argumentsforsynchronizesnapshot() {
        guard self.linkdestparam != nil else {
            self.arguments!.append(self.localCatalog!)
            return
        }
        self.arguments!.append(self.linkdestparam!)
        self.arguments!.append(self.localCatalog!)
        if self.offsiteServer!.isEmpty {
            self.arguments!.append(self.offsiteCatalog!)
        } else {
            self.arguments!.append(remoteargs!)
        }
    }

    init () {
        self.arguments = [String]()
    }
}
