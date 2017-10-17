//
//  TANDeviceManager.swift
//  Tango
//
//  Created by Raul Hahn on 10/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

class TANDeviceManager {
    static let sharedInstance = TANDeviceManager()
    var currentDevice: TANDevice = TANDevice()
    var tags: [TANTag] = []
    
    private init() {}
    
    // add something reactive when device is updated update also in DB(after that make a sync)
    func updateCurrentDevice(_ device: TANDevice) {
        if (currentDevice != device) {
            currentDevice = device
            dLogDebug(message: "Device has been update")
        }
    }
    
    func updateTags(_ tags: [TANTag]) {
        if (self.tags != tags) {
            self.tags = tags // liste for this change and update in DB. (reactive stuff)
            dLogInfo(message: "Tags has been update")
        }
    }
    
    func updateRegisterID(id: String) {
        if (currentDevice.uid != id) {
            currentDevice.uid = id
        }
        if isNewRegisterID(id: id) == true {
            if let deviceToken = UserDefaults.standard.string(forKey: kDeviceToken) {
                TANApiHandler().registerAppFromDevice(deviceToken: deviceToken, completionHandler: {_,_ in })
            }
        }
    }
    
    func isNewRegisterID(id: String) -> Bool {
        if let savedID = UserDefaults.standard.string(forKey: kRegisteredID) {
            if savedID != id {
                UserDefaults.standard.set(id, forKey: kRegisteredID)
                
                return true
            }
        } else {
            UserDefaults.standard.set(id, forKey: kRegisteredID)
        }
        
        return false
    }
}
