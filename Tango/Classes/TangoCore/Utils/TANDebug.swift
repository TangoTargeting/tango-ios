//
//  TANDebug.swift
//  Tango
//
//  Created by Raul Hahn on 14/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

#if DEBUG
    func dLogDebug(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
        NSLog("[\(filename):\(line)] \(function) - [Debug] - 🔹🔹🔹 \(message)")
    }
    func dLogInfo(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
        NSLog("[\(filename):\(line)] \(function) - [Info] - ℹ️ℹ️ℹ️ - \(message)")
    }
    func dLogError(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
        NSLog("[\(filename):\(line)] \(function) - [Error] - ‼️‼️‼️ \(message)")
    }
    func dLogLocalNotifInfo(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
        NSLog("[\(filename):\(line)] \(function) - [LocalNotification] - 🏰🏰🏰 - \(message)")
    }
    func dLogLocationInfo(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
        NSLog("[\(filename):\(line)] \(function) - [Location] - 🏝🏝🏝 - \(message)")
    }
#else
    func dLogInfo(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    }
    func dLogError(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    }
    func dLogDebug(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    }
    func dLogLocalNotifInfo(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    }
    func dLogLocationInfo(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    }
#endif
func aLog(message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    NSLog("[\(filename):\(line)] \(function) - \(message)")
}
