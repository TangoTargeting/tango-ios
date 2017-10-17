//
//  CampaignSpecificDate+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 2/23/17.
//
//

import Foundation
import CoreData


extension CampaignSpecificDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignSpecificDate> {
        return NSFetchRequest<CampaignSpecificDate>(entityName: "CampaignSpecificDate");
    }

    @NSManaged public var year: Int16
    @NSManaged public var dayOfYear: Int16
    @NSManaged public var fromMinute: Int16
    @NSManaged public var toMinute: Int16
    @NSManaged public var schedulerSpecificDates: CampaignSchedulerSpecificDates?

}
