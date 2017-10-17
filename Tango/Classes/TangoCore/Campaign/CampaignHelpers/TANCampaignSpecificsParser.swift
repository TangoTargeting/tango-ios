//
//  TANCampaignSpecificsHelper.swift
//  Tango
//
//  Created by Raul Hahn on 24/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import CoreData

struct SpecificsKeys {
    let skipNotifications = "skip_notification"
    let requiredAllExcludedKeywords = "require_all_excluded_keywords"
    let requiredAllIncludedKeywords = "require_all_included_keywords"
    let excludeKeywords = "exclude_keywords"
    let includeKeywords = "include_keywords"
    let minimumDisplayInterval = "minimum_display_interval_seconds"
    let displayIntervalSeconds = "display_interval_seconds"
    let secondsToDisplay =  "seconds_to_display"
}

class TANCampaignSpecificsParser {
    func campaignSpecificsFromDictionary(jsonDictionary: JSONDictionary, campaignID: String) throws -> CampaignSpecifics? {
        let k = SpecificsKeys()
        guard let requiredAllExcludedKeywords = jsonDictionary[k.requiredAllExcludedKeywords] as? Bool else {
            throw SerializationError.missing("requiredAllExcludedKeywords")
        }
        guard let requiredAllIncludedKeywords = jsonDictionary[k.requiredAllIncludedKeywords] as? Bool else {
            throw SerializationError.missing("requiredAllIncludedKeywords")
        }
        guard let excludeKeywordsDictionary = jsonDictionary[k.excludeKeywords] as? Array<Any> else {
            throw SerializationError.missing("excludeKeywords Dictionary")
        }
        guard let includeKeywordsDictionary = jsonDictionary[k.includeKeywords] as? Array<Any> else {
            throw SerializationError.missing("includeKeywords Dictionary")
        }
        guard let minimumDisplayInterval = jsonDictionary[k.minimumDisplayInterval] as? Int16 else {
            throw SerializationError.missing("minimumDisplayInterval")
        }
        guard let displayIntervalSeconds = jsonDictionary[k.displayIntervalSeconds] as? Int16 else {
            throw SerializationError.missing("displayIntervalSeconds")
        }
        guard let secondsToDisplay = jsonDictionary[k.secondsToDisplay] as? Int16 else {
            throw SerializationError.missing("secondsToDisplay")
        }
        
        if let campaignSpecifics = campaignSpecifics(campaignID: campaignID) {
            campaignSpecifics.requireAllExcludedKeywords = requiredAllExcludedKeywords
            campaignSpecifics.requireAllIncludedKeywords = requiredAllIncludedKeywords
            campaignSpecifics.addToExcludeKeywords(NSSet.init(array: createKeywordsFromArray(keywordsArray: excludeKeywordsDictionary)))
            campaignSpecifics.addToIncludedKeywords(NSSet.init(array: createKeywordsFromArray(keywordsArray: includeKeywordsDictionary)))
            campaignSpecifics.minimumDisplayIntervalSec = minimumDisplayInterval
            campaignSpecifics.displayIntervalSec = displayIntervalSeconds
            campaignSpecifics.secondsToDisplay = secondsToDisplay
            
            return campaignSpecifics
        }
        
        return nil
    }
    
    private func createKeywordsFromArray(keywordsArray: Array<Any>) -> [CampaignSpecificsKeywords] {
        var keywords:Array<CampaignSpecificsKeywords> = []
        for (_, value) in keywordsArray.enumerated() {
            if let keyword = value as? String {
                if let campaignSpecificsKeyword = campaigKeyword(keyword: keyword) {
                    keywords.append(campaignSpecificsKeyword)
                }
            }
        }
        
        return keywords
    }
    
    private func campaignSpecifics(campaignID: String) -> CampaignSpecifics? {
        var campaignSpecifics: CampaignSpecifics?
        if let fetchedSpecifics = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignSpecifics.self), predicate: NSPredicate(format: "campaign.campaignID == %@", campaignID)) as? CampaignSpecifics {
            campaignSpecifics = fetchedSpecifics
        } else if let newSpecifics = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignSpecifics.self)) as? CampaignSpecifics {
            campaignSpecifics = newSpecifics
        }
        
        return campaignSpecifics
    }
    
    private func campaigKeyword(keyword: String) -> CampaignSpecificsKeywords? {
        var specificsKeyword: CampaignSpecificsKeywords?
        if let fetchedSpecifics = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignSpecificsKeywords.self), predicate: NSPredicate(format: "keyword == %@", keyword)) as? CampaignSpecificsKeywords {
            specificsKeyword = fetchedSpecifics
        } else if let newSpecifics = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignSpecifics.self)) as? CampaignSpecificsKeywords {
            newSpecifics.keyword = keyword
            specificsKeyword = newSpecifics
        }
        
        return specificsKeyword
    }
}
