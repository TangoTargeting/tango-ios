//
//  TANCampaignLimitsHelper.swift
//  Tango
//
//  Created by Raul Hahn on 24/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

struct CampaignLimitsKeys {
    static let endTime = "end_time"
    static let beginTime = "begin_time"
    static let maxClicksPerDevice = "max_clicks_per_device"
    static let maxDisplaysPerDevice = "max_displays_per_device"
}

class TANCampaignLimitsParser {
    func campaignLimitsFromDictionary(jsonDictionary: JSONDictionary, campaignID: String) throws -> CampaignLimits? {
        do {
            let limits = try validateDictionary(jsonDictionary)
            if let campaignLimits = campaignLimits(campaignID: campaignID) {
                if let endTime = limits.endTime?.dateFromGMTRepresentation() as NSDate? {
                    campaignLimits.endTime = endTime
                }
                if let beginTime = limits.beginTime?.dateFromGMTRepresentation() as NSDate? {
                    campaignLimits.beginTime = beginTime
                }
                campaignLimits.maxClicksPerDevice = limits.maxClicksPerDevice
                campaignLimits.maxDisplayPerDevice = limits.maxDisplaysPerDevice
                
                return campaignLimits
            }
        } catch SerializationError.missing(let value) {
            throw SerializationError.missing(value)
        }

        return nil
    }
    
    private func campaignLimits(campaignID: String) -> CampaignLimits? {
        var campaignLimits: CampaignLimits?
        if let fetchedLimits = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName:String(describing: CampaignLimits.self),
                                                                                            predicate: NSPredicate(format: "campaign.campaignID == %@", campaignID)) as? CampaignLimits {
            campaignLimits = fetchedLimits
        } else if let newLimits = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignLimits.self)) as? CampaignLimits {
            campaignLimits = newLimits
        }
        
        return campaignLimits
    }
    
    private func validateDictionary(_ jsonDictionary: JSONDictionary) throws -> (endTime: String?, beginTime: String?, maxClicksPerDevice: Int16, maxDisplaysPerDevice: Int16) {
        guard let maxClicksPerDevice = jsonDictionary[CampaignLimitsKeys.maxClicksPerDevice] as? Int16 else {
            throw SerializationError.missing("maxClicksPerDevice")
        }
        guard let maxDisplaysPerDevice = jsonDictionary[CampaignLimitsKeys.maxDisplaysPerDevice] as? Int16 else {
            throw SerializationError.missing("maxDisplaysPerDevice")
        }
        
        return (jsonDictionary[CampaignLimitsKeys.endTime] as? String, jsonDictionary[CampaignLimitsKeys.beginTime] as? String, maxClicksPerDevice, maxDisplaysPerDevice)
    }
}
