//
//  CampaignDate+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 2/23/17.
//
//

import Foundation
import CoreData


extension CampaignDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignDate> {
        return NSFetchRequest<CampaignDate>(entityName: "CampaignDate");
    }

    @NSManaged public var dayOfYear: Int16
    @NSManaged public var hour: Int16
    @NSManaged public var minute: Int16
    @NSManaged public var year: Int16
    @NSManaged public var schedulerEndDate: CampaignScheduler?
    @NSManaged public var schedulerStartDate: CampaignScheduler?

}
