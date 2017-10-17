//
//  CampaignTargetsLocations+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 30/03/17.
//
//

import Foundation
import CoreData


extension CampaignTargetsLocations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignTargetsLocations> {
        return NSFetchRequest<CampaignTargetsLocations>(entityName: "CampaignTargetsLocations");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var locationID: String?
    @NSManaged public var longitude: Double
    @NSManaged public var meters: Double
    @NSManaged public var onEnter: Bool
    @NSManaged public var onExit: Bool
    @NSManaged public var onStay: Int16
    @NSManaged public var campaignTarget: CampaignTargets?

}
