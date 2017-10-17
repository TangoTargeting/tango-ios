//
//  TANRichNotifUtils.swift
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

func resourceURL(forUrlString urlString: String) -> URL? {
    return URL(string: urlString)
}
