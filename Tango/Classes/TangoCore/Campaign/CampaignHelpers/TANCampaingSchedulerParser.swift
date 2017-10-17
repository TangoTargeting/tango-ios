//
//  TANCampaingSchedulerParser.swift
//  Tango
//
//  Created by Raul Hahn on 20/01/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

struct SchedulerKeys {
    static let useLocalTime = "use_local_time"
    static let startDate = "start"
    static let endDate = "end"
    static let repeatInterval = "repeat"
    static let specificDates = "specific_dates"
}

class TANCampaingSchedulerParser {
    func campaignSchedule(jsonDictionary: JSONDictionary, campaignID: String) throws -> CampaignScheduler? {
        guard let startDictionary = jsonDictionary[SchedulerKeys.startDate] as? JSONDictionary else {
            throw SerializationError.missing("start date dictionary")
        }

        let useLocalTime: Bool = jsonDictionary[SchedulerKeys.useLocalTime] as? Bool ?? true
        
        let repeatDictionary = jsonDictionary[SchedulerKeys.repeatInterval] as? JSONDictionary
        let specificDatesArray = jsonDictionary[SchedulerKeys.specificDates] as? [JSONDictionary]
        if repeatDictionary == nil && specificDatesArray == nil {
            throw SerializationError.missing("repeat and specific dates are missing both. One should be valid.")
        }
        var repeatInterval: CampaignSchedulerRepeat?
        if let repeatDictionary = repeatDictionary {
            do {
                repeatInterval = try TANCampaignSchedulerRepeatParser().campaignRepeatScheduler(jsonDictionary: repeatDictionary, campaignID: campaignID)
            } catch SerializationError.missing(let value) {
                throw SerializationError.missing(value)
            }
        }
        var specificDates: CampaignSchedulerSpecificDates?
        if let specificDatesArray = specificDatesArray {
            do {
                specificDates = try TANCampaignSpecificDatesParser().campaignSpecificDates(daysArray: specificDatesArray, campaignID: campaignID)
            } catch SerializationError.missing(let value) {
                throw SerializationError.missing(value)
            }
        }
        
        var startDate: CampaignDate?
        do {
            startDate = try TANCampaignDateParser().campaignDate(jsonDictionary: startDictionary, campaignID: campaignID)
            if startDate?.year == 0 {
                    if let specificDate = specificDates?.specificDates?.allObjects.first as? CampaignSpecificDate {
                        startDate?.year = specificDate.year
                        startDate?.dayOfYear = specificDate.dayOfYear != 0 ? specificDate.dayOfYear - 1 : 0
                        startDate?.hour = Int16(hoursFromMinutes(minutes: Int(specificDate.fromMinute)))
                        startDate?.minute = Int16(remainingMinutesThatAreNotHours(minutes: Int(specificDate.fromMinute)))
                }
            }
        } catch SerializationError.missing(let value) {
            throw SerializationError.missing(value)
        }
        
        var endDate: CampaignDate?
        if let endDictionary = jsonDictionary[SchedulerKeys.endDate] as? JSONDictionary {
            do {
                endDate = try TANCampaignDateParser().campaignDate(jsonDictionary: endDictionary, campaignID: campaignID)
                if endDate?.year == 0 {
                    let currentDateComponents = Date().dateComponents()
                    endDate?.year = Int16(currentDateComponents.year ?? 0) + 1
                    endDate?.dayOfYear = Int16(currentDateComponents.day ?? 0)
                    endDate?.hour = Int16(currentDateComponents.hour ?? 0)
                    endDate?.minute = Int16(currentDateComponents.minute ?? 0)
                }
            } catch SerializationError.missing(let value) {
                throw SerializationError.missing(value)
            }
        }
        
        if let scheduler = schedulerManagedObject(campaignID: campaignID) {
            scheduler.startDate = startDate
            scheduler.endDate = endDate
            scheduler.useLocalTime = useLocalTime
            scheduler.repeatInterval = repeatInterval
            scheduler.specificDates = specificDates

            return scheduler
        }
        
        return nil
    }
    
    private func schedulerManagedObject(campaignID: String) -> CampaignScheduler? {
        var scheduler: CampaignScheduler?
        if let fetchedScheduler = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName:String(describing: CampaignScheduler.self),
                                                                                            predicate: NSPredicate(format: "campaign.campaignID == %@", campaignID)) as? CampaignScheduler {
            scheduler = fetchedScheduler
        } else if let newScheduler = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignScheduler.self)) as? CampaignScheduler {
            scheduler = newScheduler
        }
        
        return scheduler
    }
}
