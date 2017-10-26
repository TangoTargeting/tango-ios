//
//  Tango.swift
//  Tango
//
//  Created by Raul Hahn on 10/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications
@objc
public class Tango: NSObject {
    /**
     This method is used for initialize the sdk with apiKey
     - Parameters:
        - apiKey: the apiKey string
     */
    @objc
    public class func initialize(tango apiKey: String) {
        TANTangoService.sharedInstance.setupApiKey(apiKey: apiKey)
    }

    @objc
    public class func initialize(tangoConfig: TangoConfig) {
        TANTangoService.sharedInstance.setupWithTangoConfig(config: tangoConfig)
    }
    /**
    The Tango identifier for device.
     */
    @objc
    public class func identifier() -> String {
        return registeredID()
    }
    
    /// Call this method only for versions of os smaller than 10.0
    @objc
    public class func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        PushNotification.application(application, didRegister: notificationSettings)
    }
    @objc
    public class func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotification.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    @objc
    public class func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotification.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    @objc
    public class func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        TANTangoService.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    /**
     Use this method when you have a custom trigger campaign on your device an you want to trigger it on your action.
    - Parameters:
        - key: the string that you defined as a triggerKey when you created the campaign.
     */
    @objc
    public class func trigger(key: String) {
        CustomTrigger.trigger(triggerKey: key)
    }
    
    /**
     Use this method to register new segments for your device.
     - Parameters:
        - segments: an array of strings, each strings represent a segment.
     */
    @objc
    public class func registerSegments(segments: [String]) {
        TANTangoService.sharedInstance.registerSegments(segments: segments)
    }
    @objc
    public class func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        TANNotificationService.sharedInstance.application(application, didReceive: notification)
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    @available(iOS 10.0, *)
    @objc public class func userNotificationCenter(_ center: UNUserNotificationCenter,
                                             didReceive response: UNNotificationResponse,
                                             withCompletionHandler
        completionHandler: @escaping () -> Void) {
        TANNotificationService.sharedInstance.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
    
    @available(iOS 10.0, *)
    @objc public class func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        TANNotificationService.sharedInstance.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
}
