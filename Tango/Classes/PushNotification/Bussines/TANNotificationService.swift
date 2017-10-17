//
//  TANNotificationService.swift
//  Tango
//
//  Created by Raul Hahn on 28/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

enum PushNotificationType: String {
    case push = "push"
    case syncDevice = "syncDevice"
    case syncCampaigns = "syncCampaigns"
}

class TANNotificationService: NSObject {
    
    static let sharedInstance = TANNotificationService()
    
    private override init () {
        super.init()
    }
    
    // MARK: UIApplicationDelegate methods
    
    func applicationDidFinishLauching(notification: Notification) {
        UIApplication.shared.applicationIconBadgeNumber = 0 // Clear badge when app launches
        let launchOptions = notification.userInfo
        
        // Check if launched from notification
        if (launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject]) != nil {
            if let userInfo = launchOptions {
                presentDialogFromNotification(notificationUserInfo: userInfo)
            }
        }
    }
    
    func applicationWillEnterForeground(notification: Notification) {
        if UIApplication.shared.isRegisteredForRemoteNotifications == false {
            registerPushNotifications()
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        presentLocalNotification(notification: notification)
    }
    
    // MARK: Remote Notifications methods
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Save to user defaults device token.
        UserDefaults.standard.set(deviceTokenString, forKey: kDeviceToken)
        dLogInfo(message: "Registration succeded with device token: \(String(describing: deviceTokenString.data(using: String.Encoding.utf8)))")
        TANApiHandler().sendDeviceToken(token: deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        dLogError(message: "Registration to push notification failed")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        presentDialogFromNotification(notificationUserInfo: userInfo)
    }

    private func presentCampaign(campaign: Campaign) {
        // TODO:HR maybe change this aprouch. Do someting with ROP (Railway)
        // We need to do this because for PN media is not downloaded when dialog appears and user will see the media only after it is downloaded. With this approuch we display the dialog only after media is downloaded
        if let mediaSource = campaign.content?.media?.source {
            if campaign.content?.media?.imageData == nil {
                if let url = URL(string: mediaSource) {
                    data(url: url, completion: { (data, response, error) in
                        if let imageData = data {
                            campaign.content?.media?.imageData = imageData as NSData?
                        }
                        Display().displayCampaign(campaign: campaign)
                    })
                } else {
                    Display().displayCampaign(campaign: campaign)
                }
            } else {
                Display().displayCampaign(campaign: campaign)
            }
        } else {
            Display().displayCampaign(campaign: campaign)
        }
    }
    
    private func presentDialogFromNotification(notificationUserInfo: [AnyHashable : Any]) {
        // If app is in foreground this method is called when receive a remote notification, or when we open an app from a notification
        // if isAppInForeground() {
        if let campaigDataDictionary = notificationUserInfo[CampaignKeys.data] as? JSONDictionary {
            if let campaignDictionary = campaigDataDictionary[CampaignKeys.object] as? JSONDictionary {
                do {
                    if let campaign = try TANCampaignParser().campaignFromDictionary(jsonDictionary: campaignDictionary) {
                        presentCampaign(campaign: campaign)
                    }
                } catch SerializationError.missing(let value) {
                    dLogError(message: "missing: \(value)")
                } catch {
                    dLogError(message: "Error on parsing campaign from payload.")
                }
            }
        }
        // }
    }
    
    func registerPushNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    dLogInfo(message: "Notification access denied.")
                }
            }
        } else {
            DispatchQueue.main.async {
                let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
            }
        }
    }
    
    private func openActionUrl(string: String, campaignID: String?) {
        if let campaignID = campaignID {
            EventsHandler(campaignId: campaignID).addEvent(event: Event(type: .click))
        }
        if let actionUrl = URL(string: string) {
            if UIApplication.shared.canOpenURL(actionUrl) {
                openUrl(url:actionUrl)
            }
        }
    }
    
    // this method is used for ios 9 or lower.
    private func presentLocalNotification(notification: UILocalNotification) {
        if let isScheduledNotificaiton = notification.userInfo?[kIsScheduledLocalNotification] as? Bool {
            if isScheduledNotificaiton == true {
                if isAppInForeground() { // paranoia check, willPresent method should be called only when app is in background
                    if let campaignDataDictionary = notification.userInfo?[CampaignKeys.data] as? JSONDictionary {
                        if let campaignDictionary = campaignDataDictionary[CampaignKeys.object] as? JSONDictionary {
                            if let campaignID = campaignDictionary[CampaignKeys.id] as? String {
                                if let campaign = TANPersistanceManager.sharedInstance.campaignDBManager.fetchCampaign(campaignID: campaignID) {
                                    Display().displayCampaign(campaign: campaign)
                                } else {
                                    dLogError(message: "Error on fetching scheduler campaign when received local notification")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: UNUserNotificationCenterDelegate Methods
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler
        completionHandler: @escaping () -> Void) {
        
        // don't forget about open from notification event.
        if let userInfo = response.notification.request.content.userInfo as? JSONDictionary {
            if let campaignObject = campaignObject(payload: userInfo) {
                TANPersistanceManager.sharedInstance.campaignDBManager.saveCampaign(dictionary: campaignObject)
                if response.actionIdentifier == ContentKeys.secondaryAction {
                    if let urlString = actionUrl(userInfo: userInfo, actionType: .secondary) {
                        openActionUrl(string: urlString, campaignID: campaignID(payload: userInfo))
                    }
                } else {
                    // We should perform primary action also when user press on notification.
                    if let urlString = actionUrl(userInfo: userInfo, actionType: .primary) {
                        openActionUrl(string: urlString, campaignID: campaignID(payload: userInfo))
                    }
                }
            }
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let isScheduledNotificaiton = notification.request.content.userInfo[kIsScheduledLocalNotification] as? Bool {
            if isScheduledNotificaiton == true {
                if isAppInForeground() { // paranoia check, willPresent method should be called only when app is in background
                    if let campaignDataDictionary = notification.request.content.userInfo[CampaignKeys.data] as? JSONDictionary {
                        if let campaignDictionary = campaignDataDictionary[CampaignKeys.object] as? JSONDictionary {
                            if let campaignID = campaignDictionary[CampaignKeys.id] as? String {
                                if let campaign = TANPersistanceManager.sharedInstance.campaignDBManager.fetchCampaign(campaignID: campaignID) {
                                    Display().displayCampaign(campaign: campaign)
                                } else {
                                    dLogError(message: "Error on fetching scheduler campaign when received local notification")
                                }
                            }
                        }
                    }
                }
            }
        } else {
            presentDialogFromNotification(notificationUserInfo: notification.request.content.userInfo)
        }
    }
}
