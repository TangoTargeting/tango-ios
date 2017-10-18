//
//  TANNotificationCategory.swift
//  TangoDevAppSwift
//
//  Created by Raul Hahn on 12/16/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
extension UNNotificationCategory {
    //    static func tangoCategories
    
    static func tangoCategoryWithAction(actionTitle: String) -> UNNotificationCategory {
        let pushNotificationKeys = TangoPushNotificaitonKeys()
        let action = UNNotificationAction(identifier: pushNotificationKeys.firstActionIdentifier,
                                          title: actionTitle,
                                          options: UNNotificationActionOptions.foreground)
        let category = UNNotificationCategory(identifier: pushNotificationKeys.singleActionCategoryIdentifier,
                                              actions: [action],
                                              intentIdentifiers: [],
                                              options: [])
        
        return category
    }
    
    static func tangoCategoryWithActions(actionsTitles: [String]) -> UNNotificationCategory {
        let pushNotificationKeys = TangoPushNotificaitonKeys()
        let actions: [UNNotificationAction] = actionsFromTitles(actionsTitles: actionsTitles)
        let category = UNNotificationCategory(identifier: pushNotificationKeys.doubleActionCategoryIdentifier,
                                              actions: actions,
                                              intentIdentifiers: [],
                                              options: [])
        
        return category
    }
    
    private static func actionsFromTitles(actionsTitles: [String]) -> [UNNotificationAction] {
        var actions: [UNNotificationAction] = []
        
        //For now we support only 2 actions.
        for (index, actionTitle) in actionsTitles.enumerated() {
            switch index {
            case PushNotificationAction.firstAction.rawValue:
                let action = UNNotificationAction(identifier: PushNotificationAction.firstAction.actionIdentifier(),
                                                  title: actionTitle,
                                                  options: UNNotificationActionOptions.foreground)
                actions.append(action)
                
                break
            case PushNotificationAction.secondAction.rawValue:
                let action = UNNotificationAction(identifier: PushNotificationAction.secondAction.actionIdentifier(),
                                                  title: actionTitle,
                                                  options: UNNotificationActionOptions.foreground)
                actions.append(action)
                
                break
            default:break
            }
        }
        
        return actions
    }
}
