//
//  CampaignEvent+CoreDataProperties.swift
//  Tango
//
//  Created by Raul Hahn on 1/5/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation
import CoreData

extension CampaignEvent {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignEvent> {
        return NSFetchRequest<CampaignEvent>(entityName: "CampaignEvent");
    }
    
    @NSManaged public var timestamp: String?
    @NSManaged public var eventUUID: String?
    @NSManaged public var type: String?
    @NSManaged public var campaignStats: CampaignStats?
}
