//
//  TANLocalNotificationConfigurator.swift
//  Tango
//
//  Created by Raul Hahn on 1/31/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

class TANLocalNotificationComander {
    
    // MARK: public methods
    
    func addLocalNotificationRequestForBackground(content: DMDisplayContent) {
        if #available(iOS 10.0, *) {
            TangoRichNotification.setupRichContent(content: content.notificationContent(), completionHandler: { [weak self] content in
                let request = UNNotificationRequest(identifier: "TANBackgroundViewNotificationIdentifier", content: content, trigger: nil)
                self?.addRequest(request: request)
            })
        } else {
            scheduleLocalNotification(date: nil, content: content)
        }
    }
    
    func addLocalNoti1ficationRequest(scheduler: Scheduler) {
        addRequests(requests: notificationRequests(scheduler: scheduler))
    }
    
    @available(iOS 10.0, *)
    func notificationContent(campaign: Campaign) -> UNMutableNotificationContent {
        var notifContent = UNMutableNotificationContent()
        if let campaignContent = campaign.content {
            if let title = campaignContent.title {
                notifContent = notificationContent(title: title, body: campaignContent.body, campaign: campaign)
            }
        }
        
        return notifContent
    }
    
    func addRequests(requests: [AnyObject]) {
        for (_, request) in requests.enumerated() {
            if #available(iOS 10.0, *) {
                if let request = request as? UNNotificationRequest {
                    if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
                        var triggerDateComponent = calendarTrigger.dateComponents
                        if triggerDateComponent.currentCalendarDate()?.compare(Date()) == .orderedDescending ||
                            triggerDateComponent.currentCalendarDate()?.compare(Date()) == .orderedSame {
                            addRequest(request: request)
                        }
                    }
                }
            } else {
                if let notification = request as? UILocalNotification {
                    if let notificationDate = notification.fireDate {
                        if notificationDate.compare(Date()) == .orderedDescending ||
                            notificationDate.compare(Date()) == .orderedSame {
                            dLogLocalNotifInfo(message: "request added: \(notification)")
                            UIApplication.shared.scheduleLocalNotification(notification)
                        }
                    }
                }
            }
        }
    }
    
    func tangoNotifications<T: NSObjectProtocol>(notifications: [T]) -> [T] {
        var tangoNotifications: [T] = []
        for (_, notification) in notifications.enumerated() {
            if isTangoNotification(notification) == true {
                tangoNotifications.append(notification)
            }
        }
        
        return tangoNotifications
    }
    
    func cancelAllTangoNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getPendingNotificationRequests {[weak self] (requests) in
                var tangoNotificationIndentifiers: [String] = []
                if let tangoNotificaitons = self?.tangoNotifications(notifications: requests) {
                    for (_, tangoNotification) in tangoNotificaitons.enumerated() {
                        dLogLocalNotifInfo(message: "request removed: \(tangoNotification)")
                        tangoNotificationIndentifiers.append(tangoNotification.identifier)
                    }
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: tangoNotificationIndentifiers)
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: tangoNotificationIndentifiers)
                }
            }
        } else {
            if let localNotifications =  UIApplication.shared.scheduledLocalNotifications {
                let tangoNotifications = self.tangoNotifications(notifications: localNotifications)
                for (_, tangoNotification) in tangoNotifications.enumerated() {
                    dLogLocalNotifInfo(message: "request removed: \(tangoNotification)")
                    UIApplication.shared.cancelLocalNotification(tangoNotification)
                }
            }
        }
    }
    
    func cancelTangoNotifications<T: NSObjectProtocol>(notifications:[T]) {
        var tangoNotificationIdentifiers: [String] = []
        for (_, notification) in notifications.enumerated() {
            if isTangoNotification(notification) == true {
                dLogLocalNotifInfo(message: "request removed: \(notification)")
                if #available(iOS 10.0, *) {
                    if let notification = notification as? UNNotificationRequest {
                        tangoNotificationIdentifiers.append(notification.identifier)
                    }
                } else {
                    if let notification = notification as? UILocalNotification {
                        UIApplication.shared.cancelLocalNotification(notification)
                    }
                }
            }
        }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: tangoNotificationIdentifiers)
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: tangoNotificationIdentifiers)
        }
    }
    
    @available(iOS 10.0, *)
    func removeExpiredRequests(pendingRequests: [UNNotificationRequest]) -> [UNNotificationRequest] {
        var expiredRequestsIdentifiers: [String] = []
        var validRequests: [UNNotificationRequest] = pendingRequests
        for (_, request) in pendingRequests.enumerated() {
            if let calendarTrigger = request.trigger as? UNCalendarNotificationTrigger {
                var triggerDateComponents = calendarTrigger.dateComponents
                if triggerDateComponents.currentCalendarDate()?.compare(Date()) == .orderedAscending {
                    expiredRequestsIdentifiers.append(request.identifier)
                    if let expiredRequestIndex = validRequests.index(of: request) {
                        validRequests.remove(at: expiredRequestIndex)
                    }
                }
            }
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: expiredRequestsIdentifiers)
        
        return validRequests
    }
    
    func notificationRequests<T>(scheduler: Scheduler) -> [T] {
        var requests: [T] = []
        let displayContent = DMDisplayContent.init(campaign: scheduler.campaign)
        for (_, scheduleDate) in scheduler.toScheduledDates.enumerated() {
            var dateComponents = DateComponents()
            dateComponents.year = scheduleDate.dateComponents().year
            dateComponents.month = scheduleDate.dateComponents().month
            dateComponents.day = scheduleDate.dateComponents().day
            dateComponents.hour = scheduleDate.dateComponents().hour
            dateComponents.minute = scheduleDate.dateComponents().minute
            if #available(iOS 10.0, *) {
                let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                TangoRichNotification.setupRichContent(content: schedulerNotificationContent(campaign: scheduler.campaign), completionHandler: { [weak self] content in
                    if let requestIdentifier = self?.notificationRequestIdentifier(campaignID: scheduler.campaign.campaignID, requestDate: scheduleDate) {
                        if  let notificationRequest = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: calendarTrigger) as? T {
                            requests.append(notificationRequest)
                        }
                    }
                })
            } else {
                if let localNotification = localNotification(date: scheduleDate, content: displayContent) as? T {
                    requests.append(localNotification)
                }
            }
        }
        
        return requests
    }
    
    // MARK: private methods
    
    @available(iOS 10.0, *)
    private func schedulerNotificationContent(campaign: Campaign) -> UNMutableNotificationContent {
        let schedulerContent = notificationContent(campaign: campaign)
        schedulerContent.userInfo[kIsScheduledLocalNotification] = true
        
        return schedulerContent
    }
    
    @available(iOS 10.0, *)
    private func addRequest(request: UNNotificationRequest) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                dLogError(message:"Error on adding notification request: \(error)")
            } else {
                dLogLocalNotifInfo(message: "request added: \(request)")
            }
        }
    }
    
    private func notificationRequestIdentifier(campaignID: String?, requestDate: Date) -> String {
        let requestDateString = requestDate.stringFromDate()
        if let campaignId = campaignID {
            let additionalString = "\(campaignId)<>\(requestDateString)"
            
            return additionalString
        }
        
        return requestDateString
    }
    
    @available(iOS 10.0, *)
    private func notificationContent(title: String, body: String?, campaign: Campaign) -> UNMutableNotificationContent {
        let notificationContent = UNMutableNotificationContent()
        if let text = body {
            notificationContent.title = title
            notificationContent.body = text
        } else {
            notificationContent.body = title
        }
        notificationContent.sound = UNNotificationSound.default()
        setupUserInfo(userInfo: &notificationContent.userInfo, campaign: campaign)
        
        return notificationContent
    }
    
    private func setupUserInfo(userInfo: inout [AnyHashable: Any], campaign: Campaign) {
        var objectContent: [AnyHashable: Any] = [:]
        objectContent[CampaignKeys.name] = campaign.name
        objectContent[CampaignKeys.id] = campaign.campaignID
        objectContent[CampaignKeys.trigger] = campaign.trigger
        objectContent[CampaignKeys.status] = campaign.status
        objectContent[CampaignKeys.ver] = campaign.version
        objectContent[CampaignKeys.content] = campaign.content?.toDictionary()
        var dataContent: [AnyHashable: Any] = [:]
        dataContent[CampaignKeys.object] = objectContent
        userInfo[CampaignKeys.data] = dataContent
    }
    
    // MARK: iOS 9 Methods
    
    func removeExpiredRequests(pendingRequests: [UILocalNotification]) -> [UILocalNotification] {
        var validRequests: [UILocalNotification] = pendingRequests
        for (_, notification) in pendingRequests.enumerated() {
            if let notificationFireDate = notification.fireDate {
                if notificationFireDate.compare(Date()) == .orderedAscending {
                    if let expiredRequestIndex = validRequests.index(of: notification) {
                        UIApplication.shared.cancelLocalNotification(notification)
                        validRequests.remove(at: expiredRequestIndex)
                    }
                }
            }
        }
        
        return validRequests
    }
    
    private func scheduleLocalNotification(date: Date?, content: DMDisplayContent) {
        if let notification = localNotification(date: date, content: content) {
            if date == nil {
                UIApplication.shared.presentLocalNotificationNow(notification)
            } else {
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        }
    }
    
    private func localNotification(date: Date?, content: DMDisplayContent) -> UILocalNotification? {
        guard let campaignID = content.campaigID() else {
            dLogError(message: "campaign ID for local notification is nil. Notification is not scheduled.")
            
            return nil
        }
        let userInfoDictionary:[AnyHashable : Any] = [CampaignKeys.id :campaignID,
            kIsScheduledLocalNotification : true]
        let localNotification = UILocalNotification()
        if let contentText = content.textLabel?.text {
            localNotification.alertTitle = content.titleLabel.text
            localNotification.alertBody = contentText
        } else {
            // if there is not body we should put the title content to body otherwise we will not see an notification alert.
            localNotification.alertBody = content.titleLabel.text
        }
        localNotification.userInfo = userInfoDictionary
        if let date = date {
            localNotification.fireDate = date
        }
        
        return localNotification
    }

}

func isTangoNotification<T: NSObjectProtocol>(_ notification: T) -> Bool {
    if #available(iOS 10.0, *) {
        if let notificationRequest = notification as? UNNotificationRequest {
            if (notificationRequest.content.userInfo[kIsScheduledLocalNotification] as? Bool) != nil {
                return true
            }
        }
    } else {
        if let notification = notification as? UILocalNotification {
            if (notification.userInfo?[kIsScheduledLocalNotification] as? Bool) != nil {
                return true
            }
        }
    }
    
    return false
}



