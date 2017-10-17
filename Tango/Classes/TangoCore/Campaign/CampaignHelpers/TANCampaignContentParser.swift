//
//  TANCampaignContentHelper.swift
//  Tango
//
//  Created by Raul Hahn on 24/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

struct ContentKeys {
    static let title = "title"
    static let body = "body"
    static let type = "type"
    static let category = "category"
    static let uri = "uri"
    static let media = "media"
    static let primaryAction = "action_primary"
    static let secondaryAction = "action_secondary"
}

class TANCampaignContentParser {
    func campaignContentFromDictionary(jsonDictionary: JSONDictionary, campaignID: String) throws -> CampaignContent? {
        do {
            let content = try contentValidated(jsonDictionary, campaignID: campaignID)
            if let campaignContent = campaignContent(campaignID: campaignID) {
                campaignContent.title = content.title
                campaignContent.body = content.body
                campaignContent.type = content.type
                campaignContent.category = content.category
                campaignContent.media = content.media
                campaignContent.primaryAction = content.primaryAction
                campaignContent.secondaryAction = content.secondaryAction

                return campaignContent
            }
        } catch SerializationError.missing(let value) {
            throw SerializationError.missing(value)
        }
        
        return nil
    }
    
    private func campaignContent(campaignID: String) -> CampaignContent? {
        var campaignContent: CampaignContent?
        if let fetchedContent = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName:String(describing: CampaignContent.self),
                                                                                      predicate: NSPredicate(format: "campaign.campaignID == %@", campaignID)) as? CampaignContent {
            campaignContent = fetchedContent
        } else  if let newContent = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignContent.self)) as? CampaignContent {
            campaignContent = newContent
        }
        
        return campaignContent
    }
    
    private func contentValidated(_ jsonDictionary: JSONDictionary, campaignID: String) throws -> (title: String, body: String?, type: String, category: String?, media: CampaignMedia?, primaryAction: CampaignAction, secondaryAction: CampaignAction?) {
        guard let title = jsonDictionary[ContentKeys.title] as? String else {
            throw SerializationError.missing("title")
        }
        guard let type = jsonDictionary[ContentKeys.type] as? String else {
            throw SerializationError.missing("type")
        }
        guard let primayActionDictionary = jsonDictionary[ContentKeys.primaryAction] as? JSONDictionary else {
            throw SerializationError.missing("PrimaryAction")
        }
        let body = jsonDictionary[ContentKeys.body] as? String
        var primaryAction: CampaignAction
        do {
            if let action = try TANCampaignActionParser().campaignAction(jsonDictionary: primayActionDictionary, campaignID: campaignID, actionType: .primary) {
                primaryAction = action
            } else {
                throw SerializationError.missing("PrimaryAction")
            }
        } catch SerializationError.missing(let value) {
            throw SerializationError.missing(value)
        }
        
        // Optional fields
        var secondaryAction: CampaignAction?
        if let secondaryActionDictionary = jsonDictionary[ContentKeys.secondaryAction] as? JSONDictionary {
            do {
                secondaryAction = try TANCampaignActionParser().campaignAction(jsonDictionary: secondaryActionDictionary, campaignID: campaignID, actionType: .secondary)
            } catch SerializationError.missing(let value) {
                throw SerializationError.missing(value)
            }
        }
        var media: CampaignMedia?
        if let mediaDictionary = jsonDictionary[ContentKeys.media] as? JSONDictionary {
            do {
                media = try TANCampaignMediaParser().campaignMedia(jsonDictionary: mediaDictionary, campaignID: campaignID)
            } catch SerializationError.missing(let value) {
                throw SerializationError.missing(value)
            }
        } else {
            dLogInfo(message: "Media dictionary is missing but is optional")
        }
        
        let category = jsonDictionary[ContentKeys.category] as? String
        
        return (title, body, type, category, media, primaryAction, secondaryAction)
    }
}

extension CampaignContent: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            return [ContentKeys.title, ContentKeys.body, ContentKeys.type, ContentKeys.media, ContentKeys.primaryAction, ContentKeys.secondaryAction]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        if key == ContentKeys.title {
            return self.title as AnyObject
        }
        if key == ContentKeys.body {
            return self.body as AnyObject
        }
        if key == ContentKeys.type {
            return self.type as AnyObject
        }
        if key == ContentKeys.media {
            return self.media as AnyObject
        }
        if key == ContentKeys.primaryAction {
            return self.primaryAction as AnyObject
        }
        if key == ContentKeys.secondaryAction {
            return self.secondaryAction as AnyObject
        }
        
        return nil
    }
    
    func toDictionary() -> NSDictionary? {
        return TANJSONEncode.toDictionary(obj: self)
    }
}

