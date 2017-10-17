//
//  TANSchedulerConfig.swift
//  Tango
//
//  Created by Raul Hahn on 1/31/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

enum SchedulerType {
    case specificDay
    case week
    case month
    case unknown
    
    static func type(campaignScheduler: CampaignScheduler) -> SchedulerType {
        if let specificDays = campaignScheduler.specificDates?.specificDates {
            if specificDays.count > 0 {
                return .specificDay
            }
        }
        if let weekdays = campaignScheduler.repeatInterval?.weekdays {
            if weekdays.count > 0 {
                return .week
            }
        }
        if let monthDays = campaignScheduler.repeatInterval?.monthdays {
            if monthDays.count > 0 {
                return .month
            }
        }
        
        return unknown
    }
}

struct Scheduler {
    let campaign: Campaign
    let startDateLimit: Date
    let endDateLimit: Date?
    let type: SchedulerType
    let toScheduledDates: [Date]
    
    func isRepeatScheduler() -> Bool {
        return type == .month || type == .week
    }
}

