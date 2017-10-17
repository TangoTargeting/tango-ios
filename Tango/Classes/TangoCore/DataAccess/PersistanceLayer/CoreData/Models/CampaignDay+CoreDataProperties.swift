//
//  CampaignDay+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 1/23/17.
//
//

import Foundation
import CoreData


extension CampaignDay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignDay> {
        return NSFetchRequest<CampaignDay>(entityName: "CampaignDay");
    }

    @NSManaged public var day: Int16
    @NSManaged public var monthdays: CampaignSchedulerRepeat?
    @NSManaged public var weekdays: CampaignSchedulerRepeat?

}
