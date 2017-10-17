//
//  CampaignTargets+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 24/11/16.
//
//

import Foundation
import CoreData


extension CampaignTargets {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignTargets> {
        return NSFetchRequest<CampaignTargets>(entityName: "CampaignTargets");
    }

    @NSManaged public var campaign: Campaign?
    @NSManaged public var locations: NSSet?

}

// MARK: Generated accessors for locations
extension CampaignTargets {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: CampaignTargetsLocations)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: CampaignTargetsLocations)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}
