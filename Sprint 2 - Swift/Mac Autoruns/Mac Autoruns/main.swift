//
//  main.swift
//  Mac Autoruns
//
//  Created by Kimo Bumanglag on 6/2/20.
//  Copyright © 2020 Kimo Bumanglag. All rights reserved.
//

import Foundation
import CryptoKit

// Globals
let launchDaemonsDir = "/Library/LaunchDaemons/"
let launchAgentsDir = "/Library/LaunchAgents/"
let userDir = "/Users/"
var autorunEntries = [AutorunEntry]()

func enumerateUsers() -> Array<URL> {
    // Enumerate the users present on the system, as identified by a home directory
    // Returns: Array of file URLs for each user's home directory
    let usernames = try? FileManager.default.contentsOfDirectory(atPath: userDir)
    var userdirs = [URL]()
    for user in usernames! {
        let userurl = URL(fileURLWithPath: userDir + user)
        userdirs.append(userurl)
    }
    return userdirs
}

func extractProgramFromPlist(plistURL: URL) -> URL {
    var format = PropertyListSerialization.PropertyListFormat.xml //format of the property list
    let fileContents = try? Data(contentsOf: plistURL)
    let plistData = try? PropertyListSerialization.propertyList(from: fileContents!,
        options: .mutableContainersAndLeaves,
        format: &format
    ) as? [String:AnyObject]
    var program = plistData!["Program"]
    if program === nil {
        let arguments = plistData!["ProgramArguments"] as! Array<Any>
        program = arguments[0] as! String as AnyObject
    }
    return URL(fileURLWithPath: program as! String)
}

func enumerateLaunchDaemons(userHomeDirs: Array<URL>) {
    let systemLaunchDaemonFiles = try? FileManager.default.contentsOfDirectory(atPath: launchDaemonsDir)
    for file in systemLaunchDaemonFiles! {
        // Enumerate System Launch Daemon entries
        let autoruntype = "System Launch Daemon"
        let filepath = launchDaemonsDir + file
        if FileManager.default.isReadableFile(atPath: filepath) {
            let fileurl = URL(fileURLWithPath: filepath)
            let program = extractProgramFromPlist(plistURL: fileurl)
            let autorunentry = AutorunEntry(filepath: filepath, programpath: program, autoruntype: autoruntype)
            autorunEntries.append(autorunentry)
        }
    }
    for userHomeDir in userHomeDirs {
        let userLaunchDaemonDir = userHomeDir.absoluteString + launchDaemonsDir
        let userLaunchDaemonFiles = try? FileManager.default.contentsOfDirectory(atPath: userLaunchDaemonDir)
        if FileManager.default.isReadableFile(atPath: userLaunchDaemonDir) {
            for file in userLaunchDaemonFiles! {
                // Enumerate User Launch Daemon entries
                let autoruntype = "User Launch Daemon"
                let filepath = userLaunchDaemonDir + file
                let fileurl = URL(fileURLWithPath: filepath)
                let program = extractProgramFromPlist(plistURL: fileurl)
                let autorunentry = AutorunEntry(filepath: filepath, programpath: program, autoruntype: autoruntype)
                autorunEntries.append(autorunentry)
            }
        }
    }
}

func enumerateLaunchAgents(userHomeDirs: Array<URL>) {
    let systemLaunchAgentFiles = try? FileManager.default.contentsOfDirectory(atPath: launchAgentsDir)
    for file in systemLaunchAgentFiles! {
        // Enumerate System Launch Agent entries
        let autoruntype = "System Launch Agent"
        let filepath = launchAgentsDir + file
        if FileManager.default.isReadableFile(atPath: filepath) {
            let fileurl = URL(fileURLWithPath: filepath)
            let program = extractProgramFromPlist(plistURL: fileurl)
            let autorunentry = AutorunEntry(filepath: filepath, programpath: program, autoruntype: autoruntype)
            autorunEntries.append(autorunentry)
        }
    }
    for userHomeDir in userHomeDirs {
        let userLaunchAgentDir = userHomeDir.path + launchAgentsDir
        let userLaunchAgentFiles = try? FileManager.default.contentsOfDirectory(atPath: userLaunchAgentDir)
        if FileManager.default.isReadableFile(atPath: userLaunchAgentDir) {
            for file in userLaunchAgentFiles! {
                // Enumerate User Launch Agent entries
                let autoruntype = "User Launch Agent"
                let filepath = userLaunchAgentDir + file
                let fileurl = URL(fileURLWithPath: filepath)
                let program = extractProgramFromPlist(plistURL: fileurl)
                let autorunentry = AutorunEntry(filepath: filepath, programpath: program, autoruntype: autoruntype)
                autorunEntries.append(autorunentry)
            }
        }
    }
}

func printResults() {
    for type in ["System Launch Daemon", "System Launch Agent", "User Launch Daemon", "User Launch Agent"] {
        print("\(type)")
        for autorunentry in autorunEntries {
            if autorunentry.autoruntype == type {
                print("\t\(autorunentry.filepath)")
                print("\t\(autorunentry.programpath)")
                print("\t\t\(autorunentry.md5)")
                print("\t\t\(autorunentry.sha1)")
                print("\t\t\(autorunentry.sha256)")
            }
        }
    }
}

let users = enumerateUsers()
enumerateLaunchDaemons(userHomeDirs: users)
enumerateLaunchAgents(userHomeDirs: users)
printResults()
