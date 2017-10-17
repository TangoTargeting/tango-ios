//
//  PushNotification.swift
//  Tango
//
//  Created by Raul Hahn on 28/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

// Use push notification featureas only using this class
// like this we can extract anytime this functionality in a sepparate framework.
class PushNotification {
    
    class func applicationDidFinishLauching(notification: Notification) {
        TANNotificationService.sharedInstance.applicationDidFinishLauching(notification: notification)
    }
    
    class func applicationWillEnterForeground(notification: Notification) {
        TANNotificationService.sharedInstance.applicationWillEnterForeground(notification: notification)
    }
        
    class func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        TANNotificationService.sharedInstance.application(application, didRegister: notificationSettings)
    }
    
    class func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        TANNotificationService.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    class func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        TANNotificationService.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    class func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        TANNotificationService.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)
    }
}
