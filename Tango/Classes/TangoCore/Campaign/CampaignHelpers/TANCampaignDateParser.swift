//
//  TANCampaignDateParser.swift
//  Tango
//
//  Created by Raul Hahn on 1/23/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

struct DateKeys {
    static let year = "year"
    static let dayOfYear = "day_of_year"
    static let hour = "hour"
    static let minute = "minute"
    static let fromMinute = "from_minute"
    static let toMinute = "to_minute"
}

class TANCampaignDateParser {
    func campaignDate(jsonDictionary: JSONDictionary, campaignID: String) throws -> CampaignDate? {
        guard let year = jsonDictionary[DateKeys.year] as? Int16 else {
            throw SerializationError.missing("year from date")
        }
        guard let day = jsonDictionary[DateKeys.dayOfYear] as? Int16 else {
            throw SerializationError.missing("dayOfYear from date")
        }
        let hour: Int16? = jsonDictionary[DateKeys.hour] as? Int16
        let minute: Int16? = jsonDictionary[DateKeys.minute] as? Int16
        if let campaignDate = dateManagedObject(year: year, day: day, hour: hour, minute: minute) {
            campaignDate.year = year
            campaignDate.dayOfYear = day
            if let hour = hour, let minute = minute {
                campaignDate.hour = hour
                campaignDate.minute = minute
            }
            
            return campaignDate
        }
        
        return nil
    }
    
    private func dateManagedObject(year: Int16, day: Int16, hour: Int16?, minute: Int16?) -> CampaignDate? {
        var campaignDate: CampaignDate?
        if let hour = hour, let minute = minute {
            if let fetchedDate = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignDate.self), predicate: NSPredicate(format: "year == %d AND dayOfYear == %d AND hour == %d AND minute == %d", year, day, hour, minute)) as? CampaignDate {
                campaignDate = fetchedDate
            } else if let newDate = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignDate.self)) as? CampaignDate {
                campaignDate = newDate
            }
        } else {
            if let fetchedDate = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignDate.self), predicate: NSPredicate(format: "year == %d AND dayOfYear == %d", year, day)) as? CampaignDate {
                campaignDate = fetchedDate
            } else if let newDate = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignDate.self)) as? CampaignDate {
                campaignDate = newDate
            }
        }
        
        return campaignDate
    }
}


class TANCampaignSpecificDateParser {
    func campaignSpecificDate(jsonDictionary: JSONDictionary, campaignID: String) throws -> CampaignSpecificDate? {
        guard let year = jsonDictionary[DateKeys.year] as? Int16 else {
            throw SerializationError.missing("year from date")
        }
        guard let day = jsonDictionary[DateKeys.dayOfYear] as? Int16 else {
            throw SerializationError.missing("dayOfYear from date")
        }
        guard let fromMinute = jsonDictionary[DateKeys.fromMinute] as? Int16 else {
            throw SerializationError.missing("fromMinute from specificDate")
        }
        guard let toMinute = jsonDictionary[DateKeys.toMinute] as? Int16 else {
            throw SerializationError.missing("toMinute from specificDate")
        }
        if let specificDate = dateManagedObject(year: year, day: day, fromMinute: fromMinute, toMinute: toMinute) {
            specificDate.year = year
            specificDate.dayOfYear = day
            specificDate.fromMinute = fromMinute
            specificDate.toMinute = toMinute
            
            return specificDate
        }
        
        return nil
    }
    
    private func dateManagedObject(year: Int16, day: Int16, fromMinute: Int16, toMinute: Int16) -> CampaignSpecificDate? {
        var campaignDate: CampaignSpecificDate?
        if let fetchedDate = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignSpecificDate.self), predicate: NSPredicate(format: "year == %d AND dayOfYear == %d AND fromMinute == %d AND toMinute == %d", year, day, fromMinute, toMinute)) as? CampaignSpecificDate {
            campaignDate = fetchedDate
        } else if let newDate = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignSpecificDate.self)) as? CampaignSpecificDate {
            campaignDate = newDate
        }
        
        return campaignDate
    }
    
}

