//
//  TANDeviceUtils.swift
//  Tango
//
//  Created by Raul Hahn on 11/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import CoreTelephony.CTCarrier
import AdSupport

extension UIDevice {
    
    static func cellularCarrierDetails() -> (carrirerName: String, countryIso: String) {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        let carrierName = carrier?.carrierName ?? ""
        let countryIso = carrier?.isoCountryCode ?? ""
        
        return (carrierName, countryIso)
    }
    
    enum DeviceModel: String {
        case iPod_Touch_5 = "iPod Touch 5"
        case iPod_Touch_6 = "iPod Touch 6"
        case iPhone_4 = "iPhone 4"
        case iPhone_4S = "iPhone 4S"
        case iPhone_5 = "iPhone 5"
        case iPhone_5C = "iPhone 5C"
        case iPhone_5S = "iPhone 5S"
        case iPhone_6 = "iPhone 6"
        case iPhone_6_Plus = "iPhone 6 Plus"
        case iPhone_6S = "iPhone 6S"
        case iPhone_6S_Plus = "iPhone 6S Plus"
        case iPhone_7 = "iPhone 7"
        case iPhone_7_Plus = "iPhone 7 Plus"
        case iPhone_SE = "iPhone SE"
        case iPad = "iPad"
        case iPad_2 = "iPad 2"
        case iPad_3 = "iPad 3"
        case iPad_4 = "iPad 4"
        case iPad_Air = "iPad Air"
        case iPad_Air_2 = "iPad Air 2"
        case iPad_Mini = "iPad Mini"
        case iPad_Mini_2 = "iPad Mini 2"
        case iPad_Mini_3 = "iPad Mini 3"
        case iPad_Mini_4 = "iPad Mini 4"
        case iPad_Pro = "iPad Pro"
        case Apple_TV = "Apple TV"
        case Simulator = "Simulator"
        case Not_Available = "Not Available"
        
        func is64BitDevice() -> Bool {
            switch self {
            case .iPhone_5, .iPhone_5C, .iPhone_5S, .iPhone_4, .iPhone_4S, .iPad, .iPad_2, .iPad_Mini:
                return false;
            default:
                return true
            }
        }
    }
    var deviceModel: DeviceModel {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return .iPod_Touch_5
        case "iPod7,1":                                 return .iPod_Touch_6
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return .iPhone_4
        case "iPhone4,1":                               return .iPhone_4S
        case "iPhone5,1", "iPhone5,2":                  return .iPhone_5
        case "iPhone5,3", "iPhone5,4":                  return .iPhone_5C
        case "iPhone6,1", "iPhone6,2":                  return .iPhone_5S
        case "iPhone7,2":                               return .iPhone_6
        case "iPhone7,1":                               return .iPhone_6_Plus
        case "iPhone8,1":                               return .iPhone_6S
        case "iPhone8,2":                               return .iPhone_6S_Plus
        case "iPhone9,1", "iPhone9,3":                  return .iPhone_7
        case "iPhone9,2", "iPhone9,4":                  return .iPhone_7_Plus
        case "iPhone8,4":                               return .iPhone_SE
        case "iPad 1,1":                                return .iPad
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return .iPad_2
        case "iPad3,1", "iPad3,2", "iPad3,3":           return .iPad_3
        case "iPad3,4", "iPad3,5", "iPad3,6":           return .iPad_4
        case "iPad4,1", "iPad4,2", "iPad4,3":           return .iPad_Air
        case "iPad5,3", "iPad5,4":                      return .iPad_Air_2
        case "iPad2,5", "iPad2,6", "iPad2,7":           return .iPad_Mini
        case "iPad4,4", "iPad4,5", "iPad4,6":           return .iPad_Mini_2
        case "iPad4,7", "iPad4,8", "iPad4,9":           return .iPad_Mini_3
        case "iPad5,1", "iPad5,2":                      return .iPad_Mini_4
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return .iPad_Pro
        case "AppleTV5,3":                              return .Apple_TV
        case "i386", "x86_64":                          return .Simulator
        default:                                        return .Not_Available
        }
    }
}

let kLimitAdvertiseID = "00000000-0000-0000-0000-000000000000"

#if swift(>=4.0)
internal func registeredID() -> String {
    var registeredID: String = ""
    if let uid = UIDevice.current.identifierForVendor?.uuidString {
        registeredID = uid
    }
    
    let shared = ASIdentifierManager.shared(),
        advertiseID = shared.advertisingIdentifier
    
    if shared.isAdvertisingTrackingEnabled && advertiseID.uuidString != kLimitAdvertiseID {
        registeredID = advertiseID.uuidString
    }
    
    return registeredID
}
#else
internal func registeredID() -> String {
    var registeredID: String = ""
    if let uid = UIDevice.current.identifierForVendor?.uuidString {
        registeredID = uid
    }
    let advertiseID = ASIdentifierManager.shared().advertisingIdentifier
    if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == true {
        if let advertiseID = advertiseID {
            if advertiseID.uuidString != kLimitAdvertiseID {
                registeredID = advertiseID.uuidString
            }
        }
    }
    
    return registeredID
}
#endif

