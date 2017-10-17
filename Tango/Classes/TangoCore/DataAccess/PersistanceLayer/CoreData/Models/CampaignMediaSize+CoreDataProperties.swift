//
//  CampaignMediaSize+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 2/22/17.
//
//

import Foundation
import CoreData


extension CampaignMediaSize {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignMediaSize> {
        return NSFetchRequest<CampaignMediaSize>(entityName: "CampaignMediaSize");
    }

    @NSManaged public var height: Float
    @NSManaged public var sizeID: String?
    @NSManaged public var width: Float
    @NSManaged public var mediaSize: CampaignMedia?

}
