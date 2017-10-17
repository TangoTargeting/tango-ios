//
//  TANDevice.swift
//  Tango
//
//  Created by Raul Hahn on 10/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

struct DeviceKeys {
    let uid = "uid"
    let type = "type"
    let appVer = "appVer"
    let major = "major"
    let minor = "minor"
    let patch = "patch"
    let sdkVer = "sdkVer"
    let os = "os"
    let family = "family"
    let codename = "codename"
    let version = "version"
    let build = "build"
    let isServerOs = "isServerOS"
    let is64Bit = "is64b"
    let osApiLevel = "osAPILevel"
    let deviceInfo = "deviceInfo"
    let carrier = "carrier"
    let name = "name"
    let udid = "udid"
    let cpuMHZ = "cpuMhz"
    let cpuModelName = "cpuModelName"
    let screen = "screen"
    let screenWidth = "sw"
    let screenHeight = "sh"
    let verticalWidth = "vw"
    let verticalHeight = "vh"
    let diag = "diagonal"
    let density = "density"
    let tags = "tags"
    let countryIso = "country_iso"
    let languageIso = "language_iso"
    let locale = "locale"
}

struct AppVersion {
    // app info
    var appMajor = 0
    var appMinor = 0
    var appPatch = 0
}

struct SdkVersion {
    // sdk info
    var sdkMajor = 0
    var sdkMinor = 0
}

struct OSInfo {
    // os info
    var osFamilyName = ""
    var osCodename = ""
    var osVersion = ""
    var osBuild = ""
    var isServerOS = 0
    var is64Bit = 0
    var osAPILevel = "0" // TODO:HR check this field ( it appears should be requierd)
}

struct DeviceScreen {
    var sw = 0
    var sh = 0
    var vw = 0
    var vh = 0
    var diag: Float = 0.0
    var density: Int = 0
}

struct DeviceInfo {
    var deviceName = ""
    
    //NSString *deviceUDID;
    var deviceCpuMhz = ""
    var deviceCpuModelName = "0"
    var deviceScreen = DeviceScreen()
    var deviceCarrier = UIDevice.cellularCarrierDetails().carrirerName
    var deviceLocale = DeviceLocale()
}

struct DeviceLocale {
    var countryIso = Locale.current.regionCode ?? UIDevice.cellularCarrierDetails().countryIso
    var languageIso = Locale.current.languageCode ?? ""
}

struct TANDevice {
    let deviceKeys = DeviceKeys.init()
    var uid = ""
    var type = ""
    var tags: [TANTag]? = []
    var appVersion = AppVersion()
    var sdkVersion = SdkVersion()
    var osInfo = OSInfo()
    var deviceInfo = DeviceInfo()
    
    init() {
        self.uid = registeredID()
        self.type = "mobile"
//        var appID = ""
//        if let ctAppID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
//            appID = ctAppID
//        }
      //  var components = appID.components(separatedBy: ".")
        // TODO:HR check this. fields
//        if components.count >= 2 {
//            if let appMinor = components[1] as? String {
//                self.appMinor = 0 // TODO:HR remove this Int(appMinor)!
//            }
//            if let appMajor = components[0] as? String {
//                self.appMajor = 0//Int(appMajor)!
//            }
//        }
        
        //TODO:HR For now we hardcoded this because on server this value is hardcoded also.
        //[[UIDevice currentDevice] systemName];
        self.osInfo = OSInfo(osFamilyName: "ios",
                             osCodename:  "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
                             osVersion: UIDevice.current.systemVersion,
                             osBuild: UIDevice.current.systemVersion,
                             isServerOS: 0,
                             is64Bit: UIDevice.current.deviceModel.is64BitDevice().intValue(),
                             osAPILevel: "0")

        let screen = DeviceScreen(sw: Int(UIScreen.main.nativeBounds.size.width),
                                  sh: Int(UIScreen.main.nativeBounds.size.height),
                                  vw:  Int(UIScreen.main.nativeBounds.size.width),
                                  vh: Int(UIScreen.main.nativeBounds.size.height),
                                  diag: screenSizeAndDensityForCurrentDevice()[deviceKeys.diag] as? Float ?? 0.0,
                                  density: screenSizeAndDensityForCurrentDevice()[deviceKeys.density] as? Int ?? 0)
        let deviceLocale = DeviceLocale(countryIso: Locale.current.regionCode ?? UIDevice.cellularCarrierDetails().countryIso, languageIso: Locale.current.languageCode ?? "")
        self.deviceInfo = DeviceInfo(deviceName: UIDevice.current.deviceModel.rawValue,
                                     deviceCpuMhz: "",
                                     deviceCpuModelName: "0",
                                     deviceScreen: screen,
                                     deviceCarrier: UIDevice.cellularCarrierDetails().carrirerName,
                                     deviceLocale: deviceLocale)
       // self.tags = []
    }
    
    func toJSON() -> String? {
        return TANJSONEncode.toJSON(obj: self)
    }
    
    func toDictionary() -> NSDictionary? {
        return TANJSONEncode.toDictionary(obj: self)
    }
}

private func screenSizeAndDensityForCurrentDevice() -> [AnyHashable: Any] {
    let device = UIDevice.current.deviceModel
    var density = 326
    var diag: Float = 3.5
    //    NSString *cpuModel = @"";
    switch device {
    case .iPhone_5, .iPhone_5C, .iPhone_5S:
        diag = 4
    case .iPhone_6, .iPhone_6S, .iPhone_7:
        diag = 4.7
    case .iPhone_6_Plus, .iPhone_6S_Plus, .iPhone_7_Plus:
        diag = 5.5
        density = 401
    case .iPad, .iPad_2:
        diag = 9.7
        density = 132
    case .iPad_3, .iPad_4, .iPad_Air, .iPad_Air_2:
        density = 264
        diag = 9.7
    case .iPad_Mini,.iPad_Mini_2, .iPad_Mini_3, .iPad_Mini_4:
        diag = 7.9
        density = 326
    default: break
    }
    
    return [DeviceKeys().density: Int(density), DeviceKeys().diag: diag]
}

extension TANDevice: Equatable {
    static func ==(first: TANDevice, second: TANDevice) -> Bool {
        return first.uid == second.uid &&
            first.type == second.type &&
            first.appVersion == second.appVersion &&
            first.sdkVersion == second.sdkVersion &&
            first.osInfo == second.osInfo &&
            first.deviceInfo == second.deviceInfo //&&
          //  first.tags == second.tags
    }
}

extension AppVersion: Equatable {
    static func ==(first: AppVersion, second: AppVersion) -> Bool {
       return  first.appMajor == second.appMajor &&
            first.appMinor == second.appMinor &&
            first.appPatch == second.appPatch
    }
}

extension SdkVersion: Equatable {
    static func ==(first: SdkVersion, second: SdkVersion) -> Bool {
        return   first.sdkMajor == second.sdkMajor &&
            first.sdkMinor == second.sdkMinor
    }
}

extension OSInfo: Equatable {
    static func ==(first: OSInfo, second: OSInfo) -> Bool {
        return   first.osFamilyName == second.osFamilyName &&
            first.osCodename == second.osCodename &&
            first.osVersion == second.osVersion &&
            first.osBuild == second.osBuild &&
            first.isServerOS == second.isServerOS &&
            first.is64Bit == second.is64Bit &&
            first.osAPILevel == second.osAPILevel
    }
}

extension DeviceScreen: Equatable {
    static func ==(first: DeviceScreen, second: DeviceScreen) -> Bool {
        return first.sw == second.sw &&
            first.sh == second.sh &&
            first.vw == second.vw &&
            first.vh == second.vh &&
            first.diag == second.diag &&
            first.density == second.density
    }
}

extension DeviceLocale: Equatable {
    static func ==(first: DeviceLocale, second: DeviceLocale) -> Bool {
        return first.countryIso == second.countryIso &&
            first.languageIso == second.languageIso
    }
}

extension DeviceInfo: Equatable {
    static func ==(first: DeviceInfo, second: DeviceInfo) -> Bool {
        return first.deviceName == second.deviceName &&
            first.deviceCpuMhz == second.deviceCpuMhz &&
            first.deviceCpuModelName == second.deviceCpuModelName &&
            first.deviceCarrier == second.deviceCarrier &&
            first.deviceScreen == second.deviceScreen &&
            first.deviceLocale == second.deviceLocale
    }
}

extension TANDevice: TANJSONDecodable {
    init?(dictionary: JSONDictionary) {
            self.uid = dictionary[deviceKeys.uid] as? String ?? ""
            self.type = dictionary[deviceKeys.type] as? String ?? ""
            
            if let appVersionDictionary = dictionary[deviceKeys.appVer] as? [String : AnyObject] {
                let appMinor = (appVersionDictionary[deviceKeys.minor] as? Int) ?? 0
                let appMajor = (appVersionDictionary[deviceKeys.major] as? Int) ?? 0
                let appPatch = (appVersionDictionary[deviceKeys.patch] as? Int) ?? 0
                self.appVersion = AppVersion(appMajor: appMajor, appMinor: appMinor, appPatch: appPatch)
            }
        
            if let sdkVersionDictionary = dictionary[deviceKeys.sdkVer] as? [String : AnyObject] {
                let sdkMajor = (sdkVersionDictionary[deviceKeys.major] as? Int) ?? 0
                let sdkMinor = (sdkVersionDictionary[deviceKeys.minor] as? Int) ?? 0
                self.sdkVersion = SdkVersion(sdkMajor: sdkMajor, sdkMinor: sdkMinor)
            }
            
            if let osDictionary = dictionary[deviceKeys.os] as? [String : AnyObject] {
                let osFamilyName = (osDictionary[deviceKeys.family] as? String) ?? ""
                let osVersion = (osDictionary[deviceKeys.version] as? String) ?? ""
                let osCodename = (osDictionary[deviceKeys.codename] as? String) ?? ""
                let osBuild = osVersion
                let isServerOS = (osDictionary[deviceKeys.isServerOs] as? Int) ?? 0
                let is64Bit =  (osDictionary[deviceKeys.is64Bit] as? Int) ?? 0
                self.osInfo = OSInfo(osFamilyName: osFamilyName,
                                    osCodename: osCodename,
                                    osVersion: osVersion,
                                    osBuild: osBuild,
                                    isServerOS: isServerOS,
                                    is64Bit: is64Bit,
                                    osAPILevel: "0") // we don't have an api value
            }
            
            //TODO:HR For now we hardcoded this because on server this value is hardcoded also.
            //[[UIDevice currentDevice] systemName];
            
            if let deviceDictionary = dictionary[deviceKeys.deviceInfo] as? [String : AnyObject] {
                let deviceName = (deviceDictionary[deviceKeys.name] as? String) ?? ""
                let deviceCpuMhz = (deviceDictionary[deviceKeys.cpuMHZ] as? String) ?? ""
                let deviceCpuModelName = (deviceDictionary[deviceKeys.cpuModelName] as? String) ?? ""
                let deviceCarrier = (deviceDictionary[deviceKeys.carrier] as? String) ?? ""
                var deviceLocale = DeviceLocale()
                if let localeDictionary = deviceDictionary[deviceKeys.locale] as? [String: AnyObject] {
                    let countryIso = (localeDictionary[deviceKeys.countryIso] as? String) ?? ""
                    let languageIso = (localeDictionary[deviceKeys.languageIso] as? String) ?? ""
                    deviceLocale = DeviceLocale(countryIso: countryIso, languageIso: languageIso)
                }
                if let screenDictionary = deviceDictionary[deviceKeys.screen] as? [String : AnyObject] {
                    let sw = (screenDictionary[deviceKeys.screenWidth] as? Int) ?? 0
                    let sh = (screenDictionary[deviceKeys.screenHeight] as? Int) ?? 0
                    let vw = (screenDictionary[deviceKeys.verticalWidth] as? Int) ?? 0
                    let vh = (screenDictionary[deviceKeys.verticalHeight] as? Int) ?? 0
                    let diag = (screenDictionary[deviceKeys.diag] as? Float) ?? 0.0
                    let density = (screenDictionary[deviceKeys.density] as? Int) ?? 0
                    let screen = DeviceScreen(sw: sw, sh: sh, vw: vw, vh: vh, diag: diag, density: density)
                    self.deviceInfo = DeviceInfo(deviceName: deviceName,
                                                 deviceCpuMhz: deviceCpuMhz,
                                                 deviceCpuModelName: deviceCpuModelName,
                                                 deviceScreen: screen,
                                                 deviceCarrier: deviceCarrier,
                                                 deviceLocale: deviceLocale)
                }
            }
            
            if let tags = dictionary[deviceKeys.tags] as? NSArray {
                self.tags = tags.map{ TANTag(tagName: $0 as! String) }
            }
        }
}

extension AppVersion: TANJSONEncodable {

    var jsonProperties:Array<String> {
        get {
            let deviceKeys = DeviceKeys()

            return [deviceKeys.major, deviceKeys.minor]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        let deviceKeys = DeviceKeys()

        if key == deviceKeys.major {
            return self.appMajor as AnyObject
        }
        if key == deviceKeys.minor {
            return self.appMinor as AnyObject
        }
        
        return nil
    }
}

extension SdkVersion: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            let deviceKeys = DeviceKeys()
            
            return [deviceKeys.major, deviceKeys.minor]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        let deviceKeys = DeviceKeys()
        
        if key == deviceKeys.major {
            return self.sdkMajor as AnyObject
        }
        if key == deviceKeys.minor {
            return self.sdkMinor as AnyObject
        }
        
        return nil
    }
}

extension OSInfo: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            let deviceKeys = DeviceKeys()
            
            return [deviceKeys.family,
                    deviceKeys.codename,
                    deviceKeys.version,
                    deviceKeys.build,
                    deviceKeys.isServerOs,
                    deviceKeys.is64Bit,
                    deviceKeys.osApiLevel]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        let deviceKeys = DeviceKeys()
        
        if key == deviceKeys.family {
            return self.osFamilyName as AnyObject
        }
        if key == deviceKeys.codename {
            return self.osCodename as AnyObject
        }
        if key == deviceKeys.version {
            return self.osVersion as AnyObject
        }
        if key == deviceKeys.build {
            return self.osBuild as AnyObject
        }
        if key == deviceKeys.isServerOs {
            return self.isServerOS as AnyObject
        }
        if key == deviceKeys.is64Bit {
            return self.is64Bit as AnyObject
        }
        if key == deviceKeys.osApiLevel {
            return self.osAPILevel as AnyObject
        }
        
        return nil
    }
}

extension DeviceLocale: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            let deviceKeys = DeviceKeys()
            
            return [deviceKeys.countryIso,
                    deviceKeys.languageIso]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        let deviceKeys = DeviceKeys()
        
        if key == deviceKeys.countryIso {
            return self.countryIso as AnyObject
        }
        if key == deviceKeys.languageIso {
            return self.languageIso as AnyObject
        }
        
        return nil
    }
}

extension DeviceScreen: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            let deviceKeys = DeviceKeys()
            
            return [deviceKeys.screenWidth,
                    deviceKeys.screenHeight,
                    deviceKeys.verticalWidth,
                    deviceKeys.verticalHeight,
                    deviceKeys.diag,
                    deviceKeys.density]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        let deviceKeys = DeviceKeys()
        
        if key == deviceKeys.screenWidth {
            return self.sw as AnyObject
        }
        if key == deviceKeys.screenHeight {
            return self.sh as AnyObject
        }
        if key == deviceKeys.verticalHeight {
            return self.vh as AnyObject
        }
        if key == deviceKeys.verticalWidth {
            return self.vw as AnyObject
        }
        if key == deviceKeys.diag {
            return self.diag as AnyObject
        }
        if key == deviceKeys.density {
            return self.density as AnyObject
        }
        
        return nil
    }
}

extension DeviceInfo: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            let deviceKeys = DeviceKeys()
            
            return [deviceKeys.name,
                    deviceKeys.cpuMHZ,
                    deviceKeys.cpuModelName,
                    deviceKeys.screen,
                    deviceKeys.carrier,
                    deviceKeys.locale]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        let deviceKeys = DeviceKeys()
        
        if key == deviceKeys.name {
            return self.deviceName as AnyObject
        }
        if key == deviceKeys.cpuMHZ {
            return self.deviceCpuMhz as AnyObject
        }
        if key == deviceKeys.cpuModelName {
            return self.deviceCpuModelName as AnyObject
        }
        if key == deviceKeys.screen {
            return self.deviceScreen as AnyObject
        }
        if key == deviceKeys.carrier {
            return self.deviceCarrier as AnyObject
        }
        if key == deviceKeys.locale {
            return self.deviceLocale as AnyObject
        }
        
        return nil
    }
}

extension TANDevice: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            return [deviceKeys.uid, deviceKeys.type, deviceKeys.appVer, deviceKeys.os, deviceKeys.deviceInfo, deviceKeys.tags]
        }
    }
    func valueForKey(key: String!) -> AnyObject! {
        if key == deviceKeys.uid {
            return self.uid as AnyObject
        }
        if key == deviceKeys.type {
            return self.type as AnyObject
        }
        if key == deviceKeys.appVer {
            return self.appVersion as AnyObject
        }
        if key == deviceKeys.os {
            return self.osInfo as AnyObject
        }
        if key == deviceKeys.deviceInfo {
            return self.deviceInfo as AnyObject
        }
//        if key == deviceKeys.tags {
//            return self.tags as AnyObject
//        }
        return nil
    }
}
