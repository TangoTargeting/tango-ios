//
//  AppDelegate.swift
//  Tango
//
//  Created by daniesy on 10/17/2017.
//  Copyright (c) 2017 daniesy. All rights reserved.
//

import UIKit
import Tango
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        
        // Initialize with API key
        Tango.initialize(tango: "your-tango-sdk-key")
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Tango.application(application, didReceiveRemoteNotification: userInfo)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Tango.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Tango.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Tango.application(application, didReceiveRemoteNotification: userInfo)
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        Tango.application(application, didRegister: notificationSettings)
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        Tango.application(application, didReceive: notification)
    }
    
    // MARK: UNUserNotificationCenterDelegate Methods
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Tango.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Tango.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }


}

