//
//  CampaignLimits+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 24/11/16.
//
//

import Foundation
import CoreData


extension CampaignLimits {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignLimits> {
        return NSFetchRequest<CampaignLimits>(entityName: "CampaignLimits");
    }

    @NSManaged public var beginTime: NSDate?
    @NSManaged public var endTime: NSDate?
    @NSManaged public var maxClicksPerDevice: Int16
    @NSManaged public var maxDisplayPerDevice: Int16
    @NSManaged public var campaign: Campaign?

}
