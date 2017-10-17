//
//  CampaignMedia+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 2/22/17.
//
//

import Foundation
import CoreData


extension CampaignMedia {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignMedia> {
        return NSFetchRequest<CampaignMedia>(entityName: "CampaignMedia");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var source: String?
    @NSManaged public var type: String?
    @NSManaged public var content: CampaignContent?
    @NSManaged public var size: CampaignMediaSize?

}
