//
//  TANCampaignSchedulerRepeatParser.swift
//  Tango
//
//  Created by Raul Hahn on 1/23/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

struct RepeatKeys {
    static let weekdays = "weekdays"
    static let monthdays = "monthdays"
    static let fromMinute = "from_minute"
    static let toMinute = "to_minute"
}

class TANCampaignSchedulerRepeatParser {
    func campaignRepeatScheduler(jsonDictionary: JSONDictionary, campaignID: String) throws -> CampaignSchedulerRepeat? {
        let weekdays: [Int16]? = jsonDictionary[RepeatKeys.weekdays] as? [Int16]
        let monthdays: [Int16]? = jsonDictionary[RepeatKeys.monthdays] as? [Int16]
        if weekdays == nil && monthdays == nil {
            throw SerializationError.missing("monthdays and weekdays are both nil")
        }
        
        var repeatWeekdays: [CampaignDay]?
        if let weekdays = weekdays {
            repeatWeekdays = daysInPeriod(days: weekdays)
        }
        
        var repeatMonthdays: [CampaignDay]?
        if let monthdays = monthdays {
            repeatMonthdays = daysInPeriod(days: monthdays)
        }
        guard let fromMinute = jsonDictionary[RepeatKeys.fromMinute] as? Int16 else {
            throw SerializationError.missing("fromMinute repeat")
        }
        guard let toMinute = jsonDictionary[RepeatKeys.toMinute] as? Int16 else {
            throw SerializationError.missing("toMinute repeat")
        }
        
        if let schedulerRepeat = repeatManagedObject(campaignID: campaignID) {
            if let repeatWeekdays = repeatWeekdays {
                schedulerRepeat.addToWeekdays(NSSet(array: repeatWeekdays))
            }
            if let repeatMonthdays = repeatMonthdays {
                schedulerRepeat.addToMonthdays(NSSet(array: repeatMonthdays))
            }
            schedulerRepeat.fromMinute = fromMinute
            schedulerRepeat.toMinute = toMinute
            
            return schedulerRepeat
        }
        
        return nil
    }
    
    private func repeatManagedObject(campaignID: String) -> CampaignSchedulerRepeat? {
        var schedulerRepeat: CampaignSchedulerRepeat?
        if let fetchedRepeat = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignSchedulerRepeat.self), predicate: NSPredicate(format: "scheduler.campaign.campaignID == %@", campaignID)) as? CampaignSchedulerRepeat {
            schedulerRepeat = fetchedRepeat
        } else if let newSchedulerRepeat = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignSchedulerRepeat.self)) as? CampaignSchedulerRepeat {
            schedulerRepeat = newSchedulerRepeat
        }
        
        return schedulerRepeat
    }
    
    private func daysInPeriod(days: Array<Int16>) -> [CampaignDay] {
        var campaignDays:[CampaignDay] = []
        for (_, value) in days.enumerated() {
            if let day = dayManagedObject(day: value) {
                campaignDays.append(day)
            }
        }
        
        return campaignDays
    }
    
    private func dayManagedObject(day: Int16) -> CampaignDay? {
        var campaignDay: CampaignDay?
        if let fetchedDay = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignDay.self), predicate: NSPredicate(format: "day == %d", day)) as? CampaignDay {
            campaignDay = fetchedDay
        } else if let newCampaign = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignDay.self)) as? CampaignDay {
            newCampaign.day = day
            campaignDay = newCampaign
        }
        
        return campaignDay
    }
}
