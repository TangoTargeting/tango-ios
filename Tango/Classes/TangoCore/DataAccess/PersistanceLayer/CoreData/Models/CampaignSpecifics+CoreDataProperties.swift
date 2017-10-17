//
//  CampaignSpecifics+CoreDataProperties.swift
//  
//
//  Created by Raul Hahn on 24/11/16.
//
//

import Foundation
import CoreData


extension CampaignSpecifics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CampaignSpecifics> {
        return NSFetchRequest<CampaignSpecifics>(entityName: "CampaignSpecifics");
    }

    @NSManaged public var displayIntervalSec: Int16
    @NSManaged public var minimumDisplayIntervalSec: Int16
    @NSManaged public var requireAllExcludedKeywords: Bool
    @NSManaged public var requireAllIncludedKeywords: Bool
    @NSManaged public var secondsToDisplay: Int16
    @NSManaged public var campaign: Campaign?
    @NSManaged public var excludeKeywords: NSSet?
    @NSManaged public var includedKeywords: NSSet?

}

// MARK: Generated accessors for excludeKeywords
extension CampaignSpecifics {

    @objc(addExcludeKeywordsObject:)
    @NSManaged public func addToExcludeKeywords(_ value: CampaignSpecificsKeywords)

    @objc(removeExcludeKeywordsObject:)
    @NSManaged public func removeFromExcludeKeywords(_ value: CampaignSpecificsKeywords)

    @objc(addExcludeKeywords:)
    @NSManaged public func addToExcludeKeywords(_ values: NSSet)

    @objc(removeExcludeKeywords:)
    @NSManaged public func removeFromExcludeKeywords(_ values: NSSet)

}

// MARK: Generated accessors for includedKeywords
extension CampaignSpecifics {

    @objc(addIncludedKeywordsObject:)
    @NSManaged public func addToIncludedKeywords(_ value: CampaignSpecificsKeywords)

    @objc(removeIncludedKeywordsObject:)
    @NSManaged public func removeFromIncludedKeywords(_ value: CampaignSpecificsKeywords)

    @objc(addIncludedKeywords:)
    @NSManaged public func addToIncludedKeywords(_ values: NSSet)

    @objc(removeIncludedKeywords:)
    @NSManaged public func removeFromIncludedKeywords(_ values: NSSet)

}
