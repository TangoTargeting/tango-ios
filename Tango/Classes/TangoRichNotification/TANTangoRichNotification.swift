//
//  TangoRichNotification.swift
//  TangoDevAppSwift
//
//  Created by Raul Hahn on 12/16/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

internal struct PayloadKeys {
    static let data = "data"
    static let media = "media"
    static let content = "content"
    static let source = "src"
    static let type = "type"
    static let primaryAction = "action_primary"
    static let secondaryAction = "action_secondary"
    static let title = "title"
    static let actionUri = "uri"
    static let object = "object"
}

enum NotificationAction {
    case first
    case second
}

typealias PayloadDictionary = [AnyHashable: Any]
typealias  MediaSummary = (url: String, type: MediaType)

@available(iOS 10.0, *)
internal class TangoRichNotification {
    internal class func setupRichContent(content: UNMutableNotificationContent,
                                         completionHandler: @escaping(UNNotificationContent) -> Void) {
        TangoRichNotification().tangoRichContent(content: content, completionHandler: completionHandler)
    }
    
    private func tangoRichContent(content: UNMutableNotificationContent, completionHandler: @escaping(UNNotificationContent) -> Void) {
        let userInfo = content.userInfo
        
        // add media attachment
        if let mediaSummary =  Media.mediaSummary(userInfo: userInfo) {
            loadAttachment(forMediaType: mediaSummary.type, withUrlString: mediaSummary.url, completionHandler: { attachment in
                if let attachment = attachment {
                    content.attachments = [attachment]
                }
            })
        }
        
        // Create new category for received notification with identifier, from payload
        var actions: [UNNotificationAction] = []
        if let firstAction = notificationAction(userInfo: userInfo, type: .first) {
            actions.append(firstAction)
        }
        if let secondAction = notificationAction(userInfo: userInfo, type: .second) {
            actions.append(secondAction)
        }
        UNUserNotificationCenter.current().setNotificationCategories([UNNotificationCategory(identifier: "dynamicAction", actions: actions,
                                                                                             intentIdentifiers: [],
                                                                                             options: [])])
        content.categoryIdentifier = "dynamicAction"
        completionHandler(content)
    }
    
    private func notificationAction(userInfo: PayloadDictionary, type: NotificationAction) -> UNNotificationAction? {
        if let dataDictionary = userInfo[PayloadKeys.data] as? PayloadDictionary {
            if let objectDictionary = dataDictionary[PayloadKeys.object] as? PayloadDictionary {
                switch type {
                case .first:
                    if let contentDictioanry = objectDictionary[PayloadKeys.content] as? PayloadDictionary {
                        if let primaryAction = contentDictioanry[PayloadKeys.primaryAction] as? PayloadDictionary {
                            if let title = primaryAction[PayloadKeys.title] as? String {
                                return UNNotificationAction(identifier: PayloadKeys.primaryAction, title: title, options: UNNotificationActionOptions.foreground)
                            }
                        }
                    }
                case .second:
                    if let contentDictioanry = objectDictionary[PayloadKeys.content] as? PayloadDictionary {
                        if let secondaryAction = contentDictioanry[PayloadKeys.secondaryAction] as? PayloadDictionary {
                            if let title = secondaryAction[PayloadKeys.title] as? String {
                                return UNNotificationAction(identifier: PayloadKeys.secondaryAction, title: title, options: UNNotificationActionOptions.foreground)
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
