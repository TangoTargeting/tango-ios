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
    static let id = "id"
}

internal let kIsScheduledLocalNotification = "isScheduledLocalNotification"

enum NotificationAction {
    case first
    case second
}

typealias JSONDictionary = [AnyHashable: Any]
typealias  MediaSummary = (url: String, type: MediaType)

@available(iOS 10.0, *)
@objc public class TangoRichNotification: NSObject {
    @objc public class func setupRichContent(content: UNMutableNotificationContent,
                                        apiKey: String,
                                       completionHandler: @escaping(UNNotificationContent) -> Void) {
        TangoRichNotification().tangoRichContent(content: content, apiKey: apiKey, completionHandler: completionHandler)
    }

    private func tangoRichContent(content: UNMutableNotificationContent, apiKey: String, completionHandler: @escaping(UNNotificationContent) -> Void) {
        let userInfo = content.userInfo
        
        // TODO:HR check if we should send an event when a local notif is received.
        if userInfo[kIsScheduledLocalNotification] == nil ||
            (userInfo[kIsScheduledLocalNotification] as? Bool) == false {
            sendPNReceivedEventToServer(payload: userInfo, apiKey: apiKey)
        }

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
    
    private func notificationAction(userInfo: JSONDictionary, type: NotificationAction) -> UNNotificationAction? {
        if let dataDictionary = userInfo[PayloadKeys.data] as? JSONDictionary {
            if let objectDictionary = dataDictionary[PayloadKeys.object] as? JSONDictionary {
                switch type {
                case .first:
                    if let contentDictioanry = objectDictionary[PayloadKeys.content] as? JSONDictionary {
                        if let primaryAction = contentDictioanry[PayloadKeys.primaryAction] as? JSONDictionary {
                            if let title = primaryAction[PayloadKeys.title] as? String {
                                return UNNotificationAction(identifier: PayloadKeys.primaryAction, title: title, options: UNNotificationActionOptions.foreground)
                            }
                        }
                    }
                case .second:
                    if let contentDictioanry = objectDictionary[PayloadKeys.content] as? JSONDictionary {
                        if let secondaryAction = contentDictioanry[PayloadKeys.secondaryAction] as? JSONDictionary {
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
