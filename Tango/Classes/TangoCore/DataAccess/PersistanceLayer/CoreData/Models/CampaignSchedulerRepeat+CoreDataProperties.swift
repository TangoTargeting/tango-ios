//
//  CampaignSchedulerRepeat+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 2/3/17.
//
//

import Foundation
import CoreData


extension CampaignSchedulerRepeat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignSchedulerRepeat> {
        return NSFetchRequest<CampaignSchedulerRepeat>(entityName: "CampaignSchedulerRepeat");
    }

    @NSManaged public var fromMinute: Int16
    @NSManaged public var toMinute: Int16
    @NSManaged public var monthdays: NSSet?
    @NSManaged public var scheduler: CampaignScheduler?
    @NSManaged public var weekdays: NSSet?

}

// MARK: Generated accessors for monthdays
extension CampaignSchedulerRepeat {

    @objc(addMonthdaysObject:)
    @NSManaged public func addToMonthdays(_ value: CampaignDay)

    @objc(removeMonthdaysObject:)
    @NSManaged public func removeFromMonthdays(_ value: CampaignDay)

    @objc(addMonthdays:)
    @NSManaged public func addToMonthdays(_ values: NSSet)

    @objc(removeMonthdays:)
    @NSManaged public func removeFromMonthdays(_ values: NSSet)

}

// MARK: Generated accessors for weekdays
extension CampaignSchedulerRepeat {

    @objc(addWeekdaysObject:)
    @NSManaged public func addToWeekdays(_ value: CampaignDay)

    @objc(removeWeekdaysObject:)
    @NSManaged public func removeFromWeekdays(_ value: CampaignDay)

    @objc(addWeekdays:)
    @NSManaged public func addToWeekdays(_ values: NSSet)

    @objc(removeWeekdays:)
    @NSManaged public func removeFromWeekdays(_ values: NSSet)

}
