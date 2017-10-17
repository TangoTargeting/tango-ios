//
//  CampaignSchedulerSpecificDates+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 2/23/17.
//
//

import Foundation
import CoreData


extension CampaignSchedulerSpecificDates {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignSchedulerSpecificDates> {
        return NSFetchRequest<CampaignSchedulerSpecificDates>(entityName: "CampaignSchedulerSpecificDates");
    }

    @NSManaged public var scheduler: CampaignScheduler?
    @NSManaged public var specificDates: NSSet?

}

// MARK: Generated accessors for specificDates
extension CampaignSchedulerSpecificDates {

    @objc(addSpecificDatesObject:)
    @NSManaged public func addToSpecificDates(_ value: CampaignSpecificDate)

    @objc(removeSpecificDatesObject:)
    @NSManaged public func removeFromSpecificDates(_ value: CampaignSpecificDate)

    @objc(addSpecificDates:)
    @NSManaged public func addToSpecificDates(_ values: NSSet)

    @objc(removeSpecificDates:)
    @NSManaged public func removeFromSpecificDates(_ values: NSSet)

}
