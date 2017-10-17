//
//  CampaignScheduler+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 2/22/17.
//
//

import Foundation
import CoreData


extension CampaignScheduler {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignScheduler> {
        return NSFetchRequest<CampaignScheduler>(entityName: "CampaignScheduler");
    }

    @NSManaged public var useLocalTime: Bool
    @NSManaged public var campaign: Campaign?
    @NSManaged public var endDate: CampaignDate?
    @NSManaged public var repeatInterval: CampaignSchedulerRepeat?
    @NSManaged public var specificDates: CampaignSchedulerSpecificDates?
    @NSManaged public var startDate: CampaignDate?

}
