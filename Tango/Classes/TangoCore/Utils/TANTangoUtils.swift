//
//  TANTangoUtils.swift
//  Tango
//
//  Created by Raul Hahn on 25/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

extension Int {
    func hexString() -> String {
        return String(format:"%02X", self)
    }
}

extension UIColor {
    convenience init?(hexString: String?) {
        guard let hexString = hexString else {
            return nil
        }
        
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

//#AARRGGBB
func hexARGBString(rgbaArray: [Float]) -> String? {
    if rgbaArray.count < 4 {
        return nil
    }
    let red = Int(rgbaArray[0]).hexString()
    let green = Int(rgbaArray[1]).hexString()
    let blue = Int(rgbaArray[2]).hexString()
    let alpha = Int((rgbaArray[3] * 255)).hexString()
    
    return "#\(alpha)\(red)\(green)\(blue)"
}

func colorArrayRGBA(hexARGB: String?) -> [Float]? {
    if let hexARGB = hexARGB {
        if let color = UIColor(hexString: hexARGB) {
            let colorRef = color.cgColor
            if let components = colorRef.components {
                if components.count == 4 {
                    let red = Float(components[0])
                    let green = Float(components[1])
                    let blue = Float(components[2])
                    let alpha = Float(components[3])
                    
                    return [red, green, blue, alpha]
                }
            }
        }
    }
    
    return nil
}

func readJSONFromFile(fileName: String, fileExtension: String) -> Any? {
    let tangoBundle = Bundle(for: Tango.self)
    if let path = tangoBundle.path(forResource: fileName, ofType: fileExtension) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            let jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            print("jsonData:\(jsonObj)")
            
            return jsonObj
        } catch let error {
            print(error.localizedDescription)
        }
    } else {
        print("Invalid filename/path.")
    }
    
    return nil
}

func isCampaignActive(campaign: Campaign) -> Bool {
    if let startDate = campaign.scheduler?.startDate?.date(),
        let endDate = campaign.scheduler?.endDate?.date(),
        let maxClicks = campaign.limits?.maxClicksPerDevice,
        let maxDisplays = campaign.limits?.maxDisplayPerDevice {
        if Date().isBetween(startDate: startDate, endDate: endDate) == true {
            let registeredDisplays = campaign.totalEvents?.totalDisplay ?? 0
            let registeredClicks = campaign.totalEvents?.totalClicks ?? 0
            if registeredClicks <= maxClicks && registeredDisplays <= maxDisplays {
                return true
            }
        }
    }
    
    // Push notification
    if campaign.limits == nil &&
        campaign.trigger == CampaignTrigger.push.rawValue {
        return true
    }
    
    dLogDebug(message: "Campaign \(campaign.campaignID ?? "") is expired")
    return false
}

func openUrl(url: URL) {
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}

func actionUrl(userInfo: JSONDictionary, actionType: ActionType) -> String? {
    if let dataDictionary = userInfo[CampaignKeys.data] as? JSONDictionary {
        if let objectDictionary = dataDictionary[CampaignKeys.object] as? JSONDictionary {
            if let contentDictionary = objectDictionary[CampaignKeys.content] as? JSONDictionary {
                switch actionType {
                case .primary:
                    if let primaryAction = contentDictionary[ContentKeys.primaryAction] as? JSONDictionary {
                        if let urlSource = primaryAction[ActionKeys.uri] as? String {
                            return urlSource
                        }
                    }
                case .secondary:
                    if let secondaryAction = contentDictionary[ContentKeys.secondaryAction] as? JSONDictionary {
                        if let urlSource = secondaryAction[ActionKeys.uri] as? String {
                            return urlSource
                        }
                    }
                }
            }
        }
    }
    
    return nil
}

func campaignObject(payload: JSONDictionary) -> JSONDictionary? {
    if let dataDictionary = payload[PayloadKeys.data] as? JSONDictionary {
        if let objectDictionary = dataDictionary[PayloadKeys.object] as? JSONDictionary {
            return objectDictionary
        }
    }
    
    return nil
}

func campaignID(payload: JSONDictionary) -> String? {
    if let campaignObject = campaignObject(payload: payload) {
        if let campaignID = campaignObject[CampaignKeys.id] as? String {
            return campaignID
        }
    }
    
    return nil
}

