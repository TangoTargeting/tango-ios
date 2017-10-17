//
//  CampaignAction+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 09/03/17.
//
//

import Foundation
import CoreData


extension CampaignAction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignAction> {
        return NSFetchRequest<CampaignAction>(entityName: "CampaignAction");
    }

    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var uri: String?
    @NSManaged public var textColorHexARGB: String?
    @NSManaged public var backgroundColorHexARGB: String?
    @NSManaged public var primaryContent: CampaignContent?
    @NSManaged public var secondaryContent: CampaignContent?

}
