//
//  AutorunEntry.swift
//  Mac Autoruns
//
//  Created by Kimo Bumanglag on 6/2/20.
//  Copyright © 2020 Kimo Bumanglag. All rights reserved.
//

import Cocoa
import CryptoKit

class AutorunEntry: NSObject {
    var filepath: String
    var programpath: String
    var autoruntype: String
    var md5: String {
        if self.autoruntype == "Cron Job" {
            return "No hash"
        }
        let fileContents = try? Data(contentsOf: URL(fileURLWithPath: self.filepath))
        let hash = CryptoKit.Insecure.MD5.hash(data: fileContents!)
        return hash.description
    }
    var sha1: String {
        if self.autoruntype == "Cron Job" {
            return "No hash"
        }
        let fileContents = try? Data(contentsOf: URL(fileURLWithPath: self.filepath))
        let hash = CryptoKit.Insecure.SHA1.hash(data: fileContents!)
        return hash.description
    }
    var sha256: String {
        if self.autoruntype == "Cron Job" {
            return "No hash"
        }
        let fileContents = try? Data(contentsOf: URL(fileURLWithPath: self.filepath))
        let hash = CryptoKit.SHA256.hash(data: fileContents!)
        return hash.description
    }
    init(filepath: String, programpath: String, autoruntype: String) {
        self.filepath = filepath
        self.programpath = programpath
        self.autoruntype = autoruntype
    }
}
