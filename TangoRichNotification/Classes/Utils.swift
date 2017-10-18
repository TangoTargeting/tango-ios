//
//  RichNotifUtils.swift
//  TangoDevAppSwift
//
//  Created by Raul Hahn on 12/16/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

struct TangoPushNotificaitonKeys {
    let firstActionIdentifier = "firstActionIdentifier"
    let secondActionIdentifier = "secondActionIdentifier"
    let singleActionCategoryIdentifier = "singleActionCategoryIdentifier"
    let doubleActionCategoryIdentifier = "doubleActionCategoryIdenfifier"
}

enum PushNotificationAction: Int {
    case firstAction
    case secondAction
    
    func actionIdentifier() -> String {
        let pushNotificationKeys = TangoPushNotificaitonKeys()
        switch self {
        case .firstAction:
            return pushNotificationKeys.firstActionIdentifier
        case .secondAction:
            return pushNotificationKeys.secondActionIdentifier
        }
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

func resourceURL(forUrlString urlString: String) -> URL? {
    return URL(string: urlString)
}

func campaignObject(payload: JSONDictionary) -> JSONDictionary? {
    if let dataDictionary = payload[PayloadKeys.data] as? JSONDictionary {
        if let objectDictionary = dataDictionary[PayloadKeys.object] as? JSONDictionary {
            return objectDictionary
        }
    }
    
    return nil
}

func campaignID(payload: JSONDictionary) -> String? {
    if let campaignObject = campaignObject(payload: payload) {
        if let campaignID = campaignObject[PayloadKeys.id] as? String {
            return campaignID
        }
    }

    return nil
}
