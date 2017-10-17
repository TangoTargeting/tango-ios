//
//  CampaignStats+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 24/11/16.
//
//

import Foundation
import CoreData


extension CampaignStats {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignStats> {
        return NSFetchRequest<CampaignStats>(entityName: "CampaignStats");
    }
    
    @NSManaged public var campaign: Campaign?
    @NSManaged public var events: NSSet?
    
}

// MARK: Generated accessors for events
extension CampaignStats {
    
    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: CampaignEvent)
    
    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: CampaignEvent)
    
    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)
    
    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)
    
}

