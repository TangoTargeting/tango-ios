//
//  TANSchedulerUtils.swift
//  Tango
//
//  Created by Raul Hahn on 1/26/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

extension CampaignDate {
    func date() -> Date? {
        guard self.year != 0 && self.dayOfYear != 0 else {
            return nil
        }
        
        let calendar = Calendar.current
        
        var januaryFirstComponents = DateComponents()
        januaryFirstComponents.year = Int(self.year)
        
        // First day of year. 1 january
        januaryFirstComponents.month = 1
        januaryFirstComponents.day = 1 // dayofMonth
        januaryFirstComponents.hour = Int(self.hour)
        januaryFirstComponents.minute = Int(self.minute)
        let januaryFirstDate = calendar.date(from: januaryFirstComponents)
        
        var campaignComponents = DateComponents()
        campaignComponents.day = Int(self.dayOfYear - 1)
        if let januaryFirstDate = januaryFirstDate {
            return calendar.date(byAdding: campaignComponents, to: januaryFirstDate)
        }
        
        return nil
    }
    
    func setupMinute(minute: Int16) -> Date? {
        let date =  self.date()
        let calendar = Calendar.current
        if let date = date {
            var customDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            customDateComponents.hour = hoursFromMinutes(minutes: Int(minute))
            customDateComponents.minute = remainingMinutesThatAreNotHours(minutes: Int(minute))
            
            return calendar.date(from: customDateComponents)
        }
        
        return nil
    }
}

extension Date {
    func stringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        return dateFormatter.string(from: self)
    }
    
    func isBetween(startDate: Date, endDate: Date) -> Bool {
        if startDate.compare(endDate) == .orderedDescending {
            return false
        }
        return (startDate...endDate).contains(self)
    }
    
    func dateComponents() -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .weekday, .day, .hour, .minute], from: self)
    }
    
    func dateByAdding(components: DateComponents) -> Date? {
        return Calendar.current.date(byAdding: components, to: self)
    }
}

extension DateComponents {
    mutating func currentCalendarDate() -> Date? {
        self.calendar = Calendar.current
        
        return  self.date
    }
}

func daysBetween(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current

    let dateComponents = calendar.dateComponents([.day], from: startDate.dateComponents(), to: endDate.dateComponents())

    return dateComponents.day ?? 0
}

func hoursFromMinutes(minutes: Int) -> Int {
    return Int(minutes / 60)
}

func remainingMinutesThatAreNotHours(minutes: Int) -> Int {
    return minutes - (hoursFromMinutes(minutes: minutes) * 60)
}

extension CampaignSpecificDate {
    func date() -> Date? {
        guard self.year != 0 && self.dayOfYear != 0 else {
            return nil
        }
        
        let calendar = Calendar.current
        
        var januaryFirstComponents = DateComponents()
        januaryFirstComponents.year = Int(self.year)
        
        // First day of year. 1 january
        januaryFirstComponents.month = 1
        januaryFirstComponents.day = 1 // dayofMonth
        januaryFirstComponents.hour = hoursFromMinutes(minutes: Int(self.fromMinute))
        januaryFirstComponents.minute = remainingMinutesThatAreNotHours(minutes: Int(self.fromMinute))
        let januaryFirstDate = calendar.date(from: januaryFirstComponents)
        
        var campaignComponents = DateComponents()
        campaignComponents.day = Int(self.dayOfYear - 1)
        if let januaryFirstDate = januaryFirstDate {
            return calendar.date(byAdding: campaignComponents, to: januaryFirstDate)
        }
        
        return nil
    }
    
    func setupMinute(minute: Int16) -> Date? {
        let date = self.date()
        let calendar = Calendar.current
        if let date = date {
            var customDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            customDateComponents.hour = hoursFromMinutes(minutes: Int(minute))
            customDateComponents.minute = remainingMinutesThatAreNotHours(minutes: Int(minute))
            
            return calendar.date(from: customDateComponents)
        }
        
        return nil
    }
}
