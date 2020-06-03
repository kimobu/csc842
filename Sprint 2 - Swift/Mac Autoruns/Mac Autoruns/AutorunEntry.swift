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
    var programpath: URL
    var autoruntype: String
    var md5: Insecure.MD5Digest {
        let fileContents = try? Data(contentsOf: URL(fileURLWithPath: self.filepath))
        let hash = CryptoKit.Insecure.MD5.hash(data: fileContents!)
        return hash
    }
    var sha1: Insecure.SHA1Digest {
        let fileContents = try? Data(contentsOf: URL(fileURLWithPath: self.filepath))
        let hash = CryptoKit.Insecure.SHA1.hash(data: fileContents!)
        return hash
    }
    var sha256: SHA256.Digest {
        let fileContents = try? Data(contentsOf: URL(fileURLWithPath: self.filepath))
        let hash = CryptoKit.SHA256.hash(data: fileContents!)
        return hash
    }
    init(filepath: String, programpath: URL, autoruntype: String) {
        self.filepath = filepath
        self.programpath = programpath
        self.autoruntype = autoruntype
    }
}
