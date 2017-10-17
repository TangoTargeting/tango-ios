//
//  CampaignTotalEvents+CoreDaataProperties.swift
//  Tango
//
//  Created by Raul Hahn on 1/5/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation
import CoreData

extension CampaignTotalEvents {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignTotalEvents> {
        return NSFetchRequest<CampaignTotalEvents>(entityName: "CampaignEventsTotal");
    }
    
    @NSManaged public var totalClose: Int16
    @NSManaged public var totalDisplay: Int16
    @NSManaged public var totalClicks: Int16
    @NSManaged public var campaign: Campaign?
}
