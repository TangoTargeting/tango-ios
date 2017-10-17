//
//  TANTangoService.swift
//  Tango
//
//  Created by Raul Hahn on 11/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

@objc
public class TangoConfig: NSObject {
    var apiKey: String
    var notificationAccess: Bool
    var locationAccess: Bool
    
    public init(apiKey: String, notificationAceess: Bool, locationAccess: Bool) {
        self.apiKey = apiKey
        self.notificationAccess = notificationAceess
        self.locationAccess = locationAccess
    }
}

class TANTangoService: NSObject, PrintObjectDescription {
    let timerInterval = 5 * 60 // 5 minutes
    static let sharedInstance = TANTangoService()
    var sdkApiKey: String?
    var isAppRegistered = false
    private let apiHandler: TANApiHandler = TANApiHandler()
    private var syncTimer = Timer()
    
    private override init() {
        super.init()
        startSyncTimer()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TANTangoService.applicationDifFinishLauching(notification:)),
                                               name: NSNotification.Name.UIApplicationDidFinishLaunching,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TANTangoService.applicationWillEnterForeground(notification:)),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var description: String {
        return TANTangoService.sharedInstance.sdkApiKey ?? "apiKey is null"
    }
    
    func setupApiKey(apiKey: String) {
        sdkApiKey = apiKey
        guard sdkApiKey != nil else {
            // TODO:HR change this on release. Throw an exception if apiKey is null
            dLogError(message: "Error - you must call setup with a non null api key")
            return
        }
        apiHandler.initialSync()
        if UIApplication.shared.isRegisteredForRemoteNotifications == false {
            TANNotificationService.sharedInstance.registerPushNotifications()
        }
        TANLocationManager.sharedInstance.requestAlwaysAuthorization()
    }
    
    func setupWithTangoConfig(config: TangoConfig) {
        sdkApiKey = config.apiKey
        guard sdkApiKey != nil else {
            dLogError(message: "Error - you must call setup with a non null api key")
            return
        }
        apiHandler.initialSync()
        if config.notificationAccess == true {
            if UIApplication.shared.isRegisteredForRemoteNotifications == false {
                TANNotificationService.sharedInstance.registerPushNotifications()
            }
        }
        if config.locationAccess == true {
            TANLocationManager.sharedInstance.requestAlwaysAuthorization()
        }
    }
    
    func registerSegments(segments:[String]) {
        var tags:[TANTag] = []
        for (_, segmentName) in segments.enumerated() {
            tags.append(TANTag(tagName: segmentName))
        }
        apiHandler.addTags(tags: tags, completionHandler: { (_,_) in})
    }
    
    // MARK: Private Methods
    
    private func isSilentNotification(payload: [AnyHashable: Any]) -> Bool {
        if let contentAvailable = payload["content-available"] as? Int {
            if contentAvailable == 1 {
                return true
            }
        } else if let aps = payload["aps"] as? [AnyHashable: Any] {
            if let alert = aps["alert"] as? [AnyHashable: Any] {
                if let _ = alert["body"] as? String {
                    dLogDebug(message: "Received remote notification with body nil, check if needs to be silent")
                    
                    return false
                }
            }
        }
        
        return false
    }
    
    private func triggerSync() {
        resetSyncTimer()
        apiHandler.syncData()
    }
    
    private func startSyncTimer() {
        syncTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timerInterval), target: self, selector: #selector(TANTangoService.triggerSyncFromTimer), userInfo: nil, repeats: true)
    }
    
    private func resetSyncTimer() {
        syncTimer.invalidate()
        startSyncTimer()
    }
    
    // MARK: Redirected AppDelegate methods 
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if isSilentNotification(payload: userInfo) {
            triggerSyncFromSilentNotification()
        } else {
            PushNotification.application(application, didReceiveRemoteNotification: userInfo)
        }
    }
    
    // MARK: AppDelegate Notification Methods
    
    @objc private func applicationDifFinishLauching(notification: Notification) {
        PushNotification.applicationDidFinishLauching(notification: notification)
    }
    
    @objc private func applicationWillEnterForeground(notification: Notification) {
        PushNotification.applicationWillEnterForeground(notification: notification)
        if !isAppRegistered {
            if let deviceToken = UserDefaults.standard.string(forKey: kDeviceToken) {
                TANApiHandler().registerAppFromDevice(deviceToken: deviceToken, completionHandler: {_,_ in })
            }
        }
        triggerSync()
    }
    
    // MARK: Sync triggers methods

    func triggerSyncFromSilentNotification() {
        dLogDebug(message: "Sync triggerd from silentNotification")
         triggerSync()
    }
    
    @objc func triggerSyncFromTimer() {
        dLogDebug(message: "Sync triggerd from timer")
        triggerSync()
    }
}
