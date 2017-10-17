//
//  Campaign+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 1/23/17.
//
//

import Foundation
import CoreData


extension Campaign {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Campaign> {
        return NSFetchRequest<Campaign>(entityName: "Campaign");
    }

    @NSManaged public var campaignID: String?
    @NSManaged public var category: String?
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var trigger: String?
    @NSManaged public var version: Float
    @NSManaged public var content: CampaignContent?
    @NSManaged public var limits: CampaignLimits?
    @NSManaged public var specifics: CampaignSpecifics?
    @NSManaged public var stats: CampaignStats?
    @NSManaged public var targets: CampaignTargets?
    @NSManaged public var totalEvents: CampaignTotalEvents?
    @NSManaged public var scheduler: CampaignScheduler?

}
