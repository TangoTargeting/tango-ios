//
//  PrimitiveExtensions.swift
//  Tango
//
//  Created by Raul Hahn on 14/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

extension Int {
    init(_ bool:Bool) {
        self = bool ? 1 : 0
    }
}

extension Bool {
    func intValue() -> Int {
        return self ? 1 : 0
    }
}

// If this gets bigger, move it to another file.
extension String {
    func dateFromGMTRepresentation() -> Date? {
        let instance: DateFormatter = DateFormatter() // TODO: HR make formatter static
        instance.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        instance.locale = Locale(identifier: "en_US_POSIX")
        instance.timeZone = TimeZone(abbreviation: "GMT")
        
        return instance.date(from: self)
    }
    
    func dateFromLocalRepresentation() -> Date? {
        let instance: DateFormatter = DateFormatter()
        instance.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        instance.locale = Locale(identifier: "en_US_POSIX")
        return instance.date(from: self)
    }
}

extension Date {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }

    func dateInLocalTimezone()  -> Date {
        return self.addingTimeInterval(TimeInterval(NSTimeZone.local.secondsFromGMT()))
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Date.iso8601Formatter.date(from: self)
    }
}
