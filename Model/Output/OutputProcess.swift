//
//  outputProcess.swift
//
//  Created by Thomas Evensen on 11/01/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable  cyclomatic_complexity

import Foundation

protocol RsyncError: class {
    func rsyncerror()
}

enum Trim {
    case one
    case two
    case three
}

final class OutputProcess {

    private var output: [String]?
    private var trimmedoutput: [String]?
    private var startIndex: Int?
    private var endIndex: Int?
    private var maxNumber: Int = 0
    weak var errorDelegate: RsyncError?

    func getMaxcount() -> Int {
        if self.trimmedoutput == nil {
            _ = self.trimoutput(trim: .two)
        }
        return self.maxNumber
    }

    func count() -> Int {
        return self.output?.count ?? 0
    }

    func getOutput() -> [String]? {
        if self.trimmedoutput != nil {
            return self.trimmedoutput
        } else {
            return self.output
        }
    }

    // Add line from output
    func addlinefromoutput (_ str: String) {
        if self.startIndex == nil {
            self.startIndex = 0
        } else {
            self.startIndex = self.output!.count + 1
        }
        str.enumerateLines { (line, _) in
            self.output!.append(line)
        }
    }

    func trimoutput(trim: Trim) -> [String]? {
        var out = [String]()
        guard self.output != nil else { return nil }
        switch trim {
        case .one:
            for i in 0 ..< self.output!.count {
                let substr = self.output![i].dropFirst(10).trimmingCharacters(in: .whitespacesAndNewlines)
                // let str = substr.components(separatedBy: " ").dropFirst(3).joined()
                let str = substr.components(separatedBy: " ").dropFirst(3).joined(separator: " ")
                if str.isEmpty == false && str.contains(".DS_Store") == false {
                    out.append("./" + str)
                }
            }
        case .two:
            for i in 0 ..< self.output!.count where self.output![i].last != "/" {
                out.append(self.output![i])
                let error = self.output![i].contains("rsync error:")
                if error {
                    self.errorDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
                    self.errorDelegate?.rsyncerror()
                }
            }
            self.endIndex = out.count
            self.maxNumber = self.endIndex!
        case .three:
            for i in 0 ..< self.output!.count {
                let substr = self.output![i].dropFirst(10).trimmingCharacters(in: .whitespacesAndNewlines)
                let str = substr.components(separatedBy: " ").dropFirst(3).joined(separator: " ")
                if str.isEmpty == false {
                    if str.contains(".DS_Store") == false {
                        out.append(str)
                    }
                }
            }
        }
        self.trimmedoutput = out
        return out
    }

    init () {
        self.output = [String]()
    }
 }
