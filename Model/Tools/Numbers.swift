//
//  numbers.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.05.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  Class for crunching numbers from rsyn output.  Numbers are
//  informal only, either used in main view or for logging purposes.
//
// swiftlint:disable cyclomatic_complexity

import Foundation

// enum for returning what is asked for
enum EnumNumbers {
    case totalNumber
    case totalDirs
    case totalNumberSizebytes
    case transferredNumber
    case transferredNumberSizebytes
    case new
    case delete
}

final class Numbers: SetConfigurations {
    // Second last String in Array rsync output of how much in what time
    private var resultRsync: String?
    // calculated number of files
    // output Array to keep output from rsync in
    private var output: [String]?
    // numbers after dryrun and stats
    var totNum: Int?
    var totDir: Int?
    var totNumSize: Double?
    var transferNum: Int?
    var transferNumSize: Double?
    var newfiles: Int?
    var deletefiles: Int?
    // Temporary numbers
    // ver 3.x - [Number of regular files transferred: 24]
    // ver 2.x - [Number of files transferred: 24]
    var files: [String]?
    // ver 3.x - [Total transferred file size: 278,642 bytes]
    // ver 2.x - [Total transferred file size: 278197 bytes]
    var filesSize: [String]?
    // ver 3.x - [Total file size: 1,016,382,148 bytes]
    // ver 2.x - [Total file size: 1016381703 bytes]
    var totfileSize: [String]?
    // ver 3.x - [Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)]
    // ver 2.x - [Number of files: 3956]
    var totfilesNum: [String]?
    // New files
    var new: [String]?
    // Delete files
    var delete: [String]?

    // Get numbers from rsync (dry run)
    func getTransferredNumbers(numbers: EnumNumbers) -> Int {
        switch numbers {
        case .totalDirs:
            return self.totDir ?? 0
        case .totalNumber:
            return self.totNum ?? 0
        case .transferredNumber:
            return self.transferNum ?? 0
        case .totalNumberSizebytes:
            let size = self.totNumSize ?? 0
            return Int(size / 1024)
        case .transferredNumberSizebytes:
            let size = self.transferNumSize ?? 0
            return Int(size / 1024)
        case .new:
            let num = self.newfiles ?? 0
            return Int(num)
        case .delete:
            let num = self.deletefiles ?? 0
            return Int(num)
        }
    }

    private func checandadjustknumbers() {
        guard self.transferNum != nil else { return }
        if self.transferNum! > 0 {
            self.totNum = (self.totNum ?? 0) - (self.transferNum ?? 0)
            self.totNumSize = (self.totNumSize ?? 0) - (self.transferNumSize ?? 0)
        }
    }

    private func resultrsyncver3() {
        guard self.files?.count ?? -1 > 0 else { return }
        guard self.filesSize?.count ?? -1 > 0 else { return }
        guard self.totfilesNum?.count ?? -1 > 0 else { return }
        guard self.totfileSize?.count ?? -1 > 0 else { return }
        guard self.new?.count ?? -1 > 0 else { return }
        guard self.delete?.count ?? -1 > 0 else { return }
        // Ver3 of rsync adds "," as 1000 mark, must replace it and then split numbers into components
        let filesPart = self.files![0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let filesPartSize = self.filesSize![0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totfilesPart = self.totfilesNum![0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totfilesPartSize = self.totfileSize![0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let newPart = self.new![0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let deletePart = self.delete![0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        // ["Number", "of", "regular", "files", "transferred:", "24"]
        // ["Total", "transferred", "file", "size:", "281653", "bytes"]
        // ["Number", "of", "files:", "3956", "(reg:", "3197", "dir:", "758", "link:", "1)"]
        // ["Total", "file", "size:", "1016385159", "bytes"]
        // ["Number" "of" "created" "files:" "0"]
        // ["Number" "of" "deleted" "files:" "0"]
        if filesPart.count > 5 { self.transferNum = Int(filesPart[5]) } else { self.transferNum = 0 }
        if filesPartSize.count > 4 { self.transferNumSize = Double(filesPartSize[4]) } else { self.transferNumSize = 0 }
        if totfilesPart.count > 5 { self.totNum = Int(totfilesPart[5]) } else { self.totNum = 0 }
        if totfilesPartSize.count > 3 { self.totNumSize = Double(totfilesPartSize[3]) } else { self.totNumSize = 0 }
        if totfilesPart.count > 7 {
            self.totDir = Int(totfilesPart[7].replacingOccurrences(of: ")", with: ""))
        } else {
            self.totDir = 0
        }
        if newPart.count > 4 { self.newfiles = Int(newPart[4]) } else { self.newfiles = 0 }
        if deletePart.count > 4 { self.deletefiles = Int(deletePart[4]) } else { self.deletefiles = 0 }
    }

    private func resultrsyncver2() {
        guard self.files?.count ?? -1 > 0 else { return }
        guard self.filesSize?.count ?? -1 > 0 else { return }
        guard self.totfilesNum?.count ?? -1 > 0 else { return }
        guard self.totfileSize?.count ?? -1 > 0 else { return }
        let filesPart = self.files![0].components(separatedBy: " ")
        let filesPartSize = self.filesSize![0].components(separatedBy: " ")
        let totfilesPart = self.totfilesNum![0].components(separatedBy: " ")
        let totfilesPartSize = self.totfileSize![0].components(separatedBy: " ")
        // ["Number", "of", "files", "transferred:", "24"]
        // ["Total", "transferred", "file", "size:", "281579", "bytes"]
        // ["Number", "of", "files:", "3956"]
        // ["Total", "file", "size:", "1016385085", "bytes"]
        if filesPart.count > 4 { self.transferNum = Int(filesPart[4]) } else { self.transferNum = 0 }
        if filesPartSize.count > 4 { self.transferNumSize = Double(filesPartSize[4]) } else { self.transferNumSize = 0 }
        if totfilesPart.count > 3 { self.totNum = Int(totfilesPart[3]) } else { self.totNum = 0 }
        if totfilesPartSize.count > 3 { self.totNumSize = Double(totfilesPartSize[3]) } else { self.totNumSize = 0 }
        // Rsync ver 2.x does not count directories, new files or deleted files
        self.totDir = 0
        self.newfiles = 0
        self.deletefiles = 0
    }

    func stats() -> String {
        let numberOfFiles = String(self.transferNum ?? 0)
        let sizeOfFiles = String(self.transferNumSize ?? 0)
        var numbers: String?
        var parts: [String]?
        guard self.resultRsync != nil else {
            let size = numberOfFiles + " files :" + sizeOfFiles + " KB" + " in just a few seconds"
            return size
        }
        if ViewControllerReference.shared.rsyncversion3 {
            // ["sent", "409687", "bytes", "", "received", "5331", "bytes", "", "830036.00", "bytes/sec"]
            let newmessage = self.resultRsync!.replacingOccurrences(of: ",", with: "")
            parts = newmessage.components(separatedBy: " ")
        } else {
            // ["sent", "262826", "bytes", "", "received", "2248", "bytes", "", "58905.33", "bytes/sec"]
            parts = self.resultRsync!.components(separatedBy: " ")
        }
        var bytesTotalsent: Double = 0
        var bytesTotalreceived: Double = 0
        var bytesTotal: Double = 0
        var bytesSec: Double = 0
        var seconds: Double = 0
        guard parts!.count > 9 else { return "0" }
        // Sent and received
        bytesTotalsent = Double(parts?[1] ?? "0") ?? 0
        bytesTotalreceived = Double(parts?[5] ?? "0") ?? 0
        if bytesTotalsent > bytesTotalreceived {
            // backup task
            // let result = resultsent! + parts![8] + " b/sec"
            bytesSec = Double(parts![8])!
            seconds = bytesTotalsent / bytesSec
            bytesTotal = bytesTotalsent
        } else {
            // restore task
            // let result = resultreceived! + parts![8] + " b/sec"
            bytesSec = Double(parts![8]) ?? 1
            seconds = bytesTotalreceived / bytesSec
            bytesTotal = bytesTotalreceived
        }
        numbers = self.formatresult(numberOfFiles: numberOfFiles, bytesTotal: bytesTotal, seconds: seconds)
        return numbers ?? ""
    }

    private func formatresult(numberOfFiles: String?, bytesTotal: Double, seconds: Double) -> String {
        // Dont have numbers of file as input
        if numberOfFiles == nil {
            return String(self.output!.count) + " files : " +
                String(format: "%.2f", (bytesTotal / 1024) / 1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        } else {
            return numberOfFiles! + " files : " +
                String(format: "%.2f", (bytesTotal / 1024) / 1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        }
    }

    init(outputprocess: OutputProcess?) {
        guard outputprocess != nil else { return }
        self.output = outputprocess!.trimoutput(trim: .two)
        // Getting the summarized output from output.
        if self.output!.count > 2 {
            self.resultRsync = (self.output![self.output!.count - 2])
        }
        self.files = self.output!.filter { ($0.contains("files transferred:")) }
        // ver 3.x - [Number of regular files transferred: 24]
        // ver 2.x - [Number of files transferred: 24]
        self.filesSize = self.output!.filter { ($0.contains("Total transferred file size:")) }
        // ver 3.x - [Total transferred file size: 278,642 bytes]
        // ver 2.x - [Total transferred file size: 278197 bytes]
        self.totfileSize = self.output!.filter { ($0.contains("Total file size:")) }
        // ver 3.x - [Total file size: 1,016,382,148 bytes]
        // ver 2.x - [Total file size: 1016381703 bytes]
        self.totfilesNum = self.output!.filter { ($0.contains("Number of files:")) }
        // ver 3.x - [Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)]
        // ver 2.x - [Number of files: 3956]
        // New files
        self.new = self.output!.filter { ($0.contains("Number of created files:")) }
        // Delete files
        self.delete = self.output!.filter { ($0.contains("Number of deleted files:")) }
        if files!.count == 1, filesSize!.count == 1, totfileSize!.count == 1, totfilesNum!.count == 1 {
            if ViewControllerReference.shared.rsyncversion3 {
                self.resultrsyncver3()
                self.checandadjustknumbers()
            } else {
                self.resultrsyncver2()
                self.checandadjustknumbers()
            }
        } else {
            // If it breaks set number of transferred files to size of output.
            self.transferNum = self.output!.count
        }
    }
}
