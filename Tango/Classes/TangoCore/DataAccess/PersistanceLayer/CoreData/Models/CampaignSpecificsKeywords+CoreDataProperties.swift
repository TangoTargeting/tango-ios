//
//  CampaignSpecificsKeywords+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 24/11/16.
//
//

import Foundation
import CoreData


extension CampaignSpecificsKeywords {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignSpecificsKeywords> {
        return NSFetchRequest<CampaignSpecificsKeywords>(entityName: "CampaignSpecificsKeywords");
    }

    @NSManaged public var keyword: String?
    @NSManaged public var campaignSpecificsExcludedKeywords: CampaignSpecifics?
    @NSManaged public var campaignSpecificsIncludedKeiwords: CampaignSpecifics?

}
