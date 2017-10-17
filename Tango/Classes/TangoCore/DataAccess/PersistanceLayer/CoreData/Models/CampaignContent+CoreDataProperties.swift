//
//  CampaignContent+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 1/9/17.
//
//

import Foundation
import CoreData


extension CampaignContent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignContent> {
        return NSFetchRequest<CampaignContent>(entityName: "CampaignContent");
    }

    @NSManaged public var category: String?
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var type: String?
    @NSManaged public var campaign: Campaign?
    @NSManaged public var media: CampaignMedia?
    @NSManaged public var primaryAction: CampaignAction?
    @NSManaged public var secondaryAction: CampaignAction?

}
