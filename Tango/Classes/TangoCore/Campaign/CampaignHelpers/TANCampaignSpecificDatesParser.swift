//
//  TANCampaignSpecificDatesParser.swift
//  Tango
//
//  Created by Raul Hahn on 1/23/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

struct SpecificDatesKeys {
    static let days = "days"
    static let fromMinute = "from_minute"
    static let toMinute = "to_minute"
}

class TANCampaignSpecificDatesParser {
    func campaignSpecificDates(daysArray: [JSONDictionary], campaignID: String) throws -> CampaignSchedulerSpecificDates? {
        var days: [CampaignSpecificDate] = []
        if daysArray.count > 0 {
            for (_, specificDateDictionary) in daysArray.enumerated() {
                do {
                    if let campaignDate = try TANCampaignSpecificDateParser().campaignSpecificDate(jsonDictionary: specificDateDictionary, campaignID: campaignID) {
                        days.append(campaignDate)
                    }
                } catch SerializationError.missing(let value) {
                    throw SerializationError.missing(value)
                }
            }
        } else {
            dLogDebug(message: "specific dates is empty.")
        }
        
        if let specificDates = specificDateManagedObject(campaignID: campaignID) {
            if days.count > 0 {
                specificDates.addToSpecificDates(NSSet(array: days))
            }
            
            return specificDates
        }
        
        return nil
    }
    
    private func specificDateManagedObject(campaignID: String) -> CampaignSchedulerSpecificDates? {
        var specificDate: CampaignSchedulerSpecificDates?
        if let fetchedSpecificDate = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignSchedulerSpecificDates.self), predicate: NSPredicate(format: "scheduler.campaign.campaignID == %@", campaignID)) as? CampaignSchedulerSpecificDates {
            specificDate = fetchedSpecificDate
        } else if let newDate = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignSchedulerSpecificDates.self)) as? CampaignSchedulerSpecificDates {
            specificDate = newDate
        }
        
        return specificDate
    }
}
