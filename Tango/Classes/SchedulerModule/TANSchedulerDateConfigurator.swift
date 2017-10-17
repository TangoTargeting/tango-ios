//
//  TANSchedulerDateConfigurator.swift
//  Tango
//
//  Created by Raul Hahn on 2/7/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

let kNumberOfDaysInWeek: Int = 7
let kMaxNumberOfDaysInMonth: Int = 31

enum RepeatIntervalType {
    case weekdays
    case monthdays
}

func campaignTriggerDates(campaignScheduler: CampaignScheduler) -> [Date]? {
    let schedulerType = SchedulerType.type(campaignScheduler: campaignScheduler)
    guard schedulerType != .unknown else {
        return nil
    }
    switch schedulerType {
    case .week,.month:
        if let repeatScheduer = campaignScheduler.repeatInterval {
            return repeatDates(campaignRepeatScheduler: repeatScheduer)
        }
    case .specificDay:
        if let specificDayScheduler = campaignScheduler.specificDates {
            return specificDates(campaignSpecificScheduler: specificDayScheduler)
        }
    default:
        return nil
    }
    
    return nil
}

private func repeatDates(campaignRepeatScheduler: CampaignSchedulerRepeat) -> [Date] {
    var interval: Set<CampaignDay> = []
    var intervalType: RepeatIntervalType
    
    if let weekdays = campaignRepeatScheduler.weekdays as? Set<CampaignDay>, weekdays.isEmpty == false {
        interval = weekdays
        intervalType = .weekdays
    } else if let monthDays = campaignRepeatScheduler.monthdays as? Set<CampaignDay>, monthDays.isEmpty == false {
        interval = monthDays
        intervalType = .monthdays
    } else {
        return []
    }
    var datesWithoutTime: [Date] = repeatDate(days: Array(interval), type: intervalType, campaignScheduler: campaignRepeatScheduler)
    let dates = setupRepeatDatesTime(dates: &datesWithoutTime, campaignScheduler: campaignRepeatScheduler)

    return dates
}

private func repeatDate(days: [CampaignDay], type: RepeatIntervalType, campaignScheduler: CampaignSchedulerRepeat) -> [Date] {
    var repeatDates: [Date] = []
    if let campaignStartDate = campaignScheduler.scheduler?.startDate?.date(), let campaignEndDate = campaignScheduler.scheduler?.endDate?.date() {
        switch type {
        case .weekdays:
            guard days.count <= kNumberOfDaysInWeek else {
                dLogError(message: "repeat scheduler weekdays has more than 7 days")
                
                return []
            }
            
            repeatDates = weekdaysBetween(startDate: campaignStartDate, endDate: campaignEndDate, weekdays: days)
            break
        case .monthdays:
            guard days.count <= kMaxNumberOfDaysInMonth else {
                dLogError(message: "repeat scheduler monthdays has more than 31 days")
                
                return []
            }
            
            repeatDates = monthdaysBetween(startDate: campaignStartDate, endDate: campaignEndDate, monthdays: days)
            break
        }
    }
    
    return repeatDates
}

private func setupRepeatDatesTime(dates: inout [Date], campaignScheduler: CampaignSchedulerRepeat) -> [Date] {
    var repeatDates: [Date] = []
    let fromMinute = Int(campaignScheduler.fromMinute)
    let hours = hoursFromMinutes(minutes: fromMinute)
    let minutes = remainingMinutesThatAreNotHours(minutes: fromMinute)
    for (_, date) in dates.enumerated() {
        var updatedComponents = date.dateComponents()
        updatedComponents.hour = hours
        updatedComponents.minute = minutes
        if let updatedDate = updatedComponents.currentCalendarDate() {
            repeatDates.append(updatedDate)
        }
    }
    
    return repeatDates
}

private func specificDates(campaignSpecificScheduler: CampaignSchedulerSpecificDates) -> [Date] {
    var specDates: [Date] = []
    if let specificDates = campaignSpecificScheduler.specificDates { // CampaignSpecificDate
        for (_, date) in specificDates.enumerated() {
            if let campaignSpecificDate = date as? CampaignSpecificDate {
                if let startDate = campaignSpecificDate.setupMinute(minute: campaignSpecificDate.fromMinute) {
                    specDates.append(startDate)
                }
            }
        }
    }
    
    return specDates
}

private func weekdaysBetween(startDate: Date, endDate: Date, weekdays: [CampaignDay]) -> [Date] {
    var repeatDates: [Date] = []
    var temporaryDateComponents: DateComponents = startDate.dateComponents()
    let intervalStep = 7
    if let temporaryDateWeekday = temporaryDateComponents.weekday {
        for (_, weekDay) in weekdays.enumerated() {
            let additionalDays: Int = Int(weekDay.day) - temporaryDateWeekday // if negative => start date weekday is forward than first weekday from array
            var additionalDaysComponents = DateComponents()
            additionalDaysComponents.day = additionalDays
            if let temporaryDateFromComponents = temporaryDateComponents.currentCalendarDate() {
                if let nextTemporaryDate = temporaryDateFromComponents.dateByAdding(components: additionalDaysComponents) {
                    var mutableNextTemporaryDate = nextTemporaryDate
                    var nextWeekComponents = DateComponents()
                    nextWeekComponents.day = 0
                    if additionalDays < 0 {
                        var addWeekComponent = DateComponents()
                        addWeekComponent.day = intervalStep
                        if let ctNextTemporaryDate = mutableNextTemporaryDate.dateByAdding(components: addWeekComponent) {
                            mutableNextTemporaryDate = ctNextTemporaryDate
                        } else {
                            continue
                        }
                    }
                    while mutableNextTemporaryDate.isBetween(startDate: startDate, endDate: endDate) == true {
                        guard let nextDate = mutableNextTemporaryDate.dateByAdding(components: nextWeekComponents) else {
                            dLogError(message: "next date in repeat weekdays cannot be created")
                            break
                        }
                        mutableNextTemporaryDate = nextDate
                        nextWeekComponents.day = intervalStep
                        if nextDate.isBetween(startDate: startDate, endDate: endDate) {
                            repeatDates.append(nextDate)
                        }
                    }
                }
            }
        }
    }
    
    return repeatDates
}

private func monthdaysBetween(startDate: Date, endDate: Date, monthdays: [CampaignDay]) -> [Date] {
    var repeatDates: [Date] = []
    var temporaryDateComponents: DateComponents = startDate.dateComponents()
    let intervalStep = 1
    for (_, monthDay) in monthdays.enumerated() {
        if let temporaryDateDay = temporaryDateComponents.day {
            let additionalDays = Int(monthDay.day) - temporaryDateDay
            var additionalDaysComponents = DateComponents()
            additionalDaysComponents.day = additionalDays
            if let temporaryDateFromComponents = temporaryDateComponents.currentCalendarDate() {
                if let nextTemporaryDate = temporaryDateFromComponents.dateByAdding(components: additionalDaysComponents) {
                    var mutableNextTemporaryDate = nextTemporaryDate
                    var nextWeekComponents = DateComponents()
                    nextWeekComponents.month = 0
                    var monthCount = 0
                    if additionalDays < 0 {
                        var addMonthComponent = DateComponents()
                        addMonthComponent.month = intervalStep
                        monthCount = monthCount + intervalStep
                        if let ctNextTemporaryDate = mutableNextTemporaryDate.dateByAdding(components: addMonthComponent) {
                            mutableNextTemporaryDate = ctNextTemporaryDate
                        } else {
                            continue
                        }
                    }
                    while mutableNextTemporaryDate.isBetween(startDate: startDate, endDate: endDate) == true {
                        guard let temporaryDateMonth = temporaryDateComponents.month else {
                            dLogError(message: "temporaryDateMonth in repeat monthdays cannot be created")

                            break
                        }
                        var monthDaysComponents = DateComponents()
                        monthDaysComponents.year = temporaryDateComponents.year
                        monthDaysComponents.month = temporaryDateMonth + monthCount
                        monthDaysComponents.day = additionalDays + temporaryDateDay
                        monthDaysComponents.hour = temporaryDateComponents.hour
                        monthDaysComponents.minute = temporaryDateComponents.minute
                        guard let nextDate = monthDaysComponents.currentCalendarDate() else {
                            break
                        }
                        if monthDaysComponents.isValidDate(in: Calendar.current) == false {
                            if let monthDayComponentsMonth = monthDaysComponents.month {
                                monthDaysComponents.month = intervalStep + monthDayComponentsMonth
                                monthCount = intervalStep + monthDayComponentsMonth
                            } else {
                                break
                            }
                            if let nextDate = monthDaysComponents.currentCalendarDate() {
                                mutableNextTemporaryDate = nextDate
                                if nextDate.isBetween(startDate: startDate, endDate: endDate) {
                                    repeatDates.append(nextDate)
                                } else {
                                    break
                                }
                            } else {
                                break
                            }
                        } else {
                            mutableNextTemporaryDate = nextDate
                            monthCount = monthCount + intervalStep
                            if nextDate.isBetween(startDate: startDate, endDate: endDate) {
                                repeatDates.append(nextDate)
                            }
                        }
                    }
                }
            }
        }
    }
    
    return repeatDates
}
