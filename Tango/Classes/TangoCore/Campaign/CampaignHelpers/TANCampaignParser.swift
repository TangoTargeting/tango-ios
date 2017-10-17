 //
 //  TANCampaignHelper.swift
 //  Tango
 //
 //  Created by Raul Hahn on 23/11/16.
 //  Copyright © 2016 Tangotargetting. All rights reserved.
 //
 
 import Foundation
 import CoreData
 
 struct CampaignKeys {
    static let data = "data"
    static let name = "name"
    static let trigger = "trigger"
    static let category = "category"
    static let stats = "stats"
    static let status = "status"
    static let ver = "ver"
    static let content = "content"
    static let specifics = "specifics"
    static let limits = "limits"
    static let targets = "targets"
    static let tags = "tags"
    static let id = "id"
    static let schedule = "schedule"
    static let object = "object"
 }
 
 struct TANCampaignParser {
    func campaignsFromArray(responseArray: [JSONDictionary]) -> [Campaign] {
        var campaigns: [Campaign] = []
        for (_ , value) in responseArray.enumerated() {
            do {
                if let campaign = try campaignFromDictionary(jsonDictionary: value) {
                    campaigns.append(campaign)
                }
            } catch SerializationError.missing(let value) {
                dLogError(message: "there vas on error with '\(value)'.")
            } catch SerializationError.notSerialized(let value) {
                dLogError(message: "Not serialized '\(value)'")
            } catch {
                dLogError(message: "Error at serialization")
            }
        }
        
        return campaigns
    }
    
    func campaignFromDictionary(jsonDictionary: JSONDictionary) throws -> Campaign? {
        guard let campaignID = jsonDictionary[CampaignKeys.id] as? String else {
            throw SerializationError.missing("campaignID")
        }
        guard let name = jsonDictionary[CampaignKeys.name] as? String else {
            throw SerializationError.missing("name")
        }
        guard let trigger = jsonDictionary[CampaignKeys.trigger] as? String else {
            throw SerializationError.missing("trigger")
        }
        guard let status = jsonDictionary[CampaignKeys.status] as? String else {
            throw SerializationError.missing("status")
        }
        guard let version = jsonDictionary[CampaignKeys.ver] as? Float else {
            throw SerializationError.missing("version")
        }
        guard let contentDictionary = jsonDictionary[CampaignKeys.content] as? JSONDictionary else {
            throw SerializationError.missing("content dictionary")
        }
        
        var scheduleDictionary: JSONDictionary?
        if trigger == CampaignTrigger.scheduler.rawValue {
            guard let schDictionary = jsonDictionary[CampaignKeys.schedule] as? JSONDictionary else {
                throw SerializationError.missing("schedule dictioanry")
            }
            scheduleDictionary = schDictionary
        } else {
            scheduleDictionary = jsonDictionary[CampaignKeys.schedule] as? JSONDictionary
        }
        
        var category: String?
        if let catFromDictionary = jsonDictionary[CampaignKeys.category] as? String {
            category = catFromDictionary
        } else {
            dLogDebug(message: "category is missing but is optional")
        }
        var content: CampaignContent?
        do {
            content = try TANCampaignContentParser().campaignContentFromDictionary(jsonDictionary: contentDictionary, campaignID: campaignID)
        } catch SerializationError.missing(let value) {
            throw SerializationError.missing(value)
        }
        var stats:CampaignStats?
        if let statsObject = parsedObject(campaignID: campaignID,
                                          jsonDictionary: jsonDictionary[CampaignKeys.stats],
                                          objectClassString: String(describing: CampaignStats.self),
                                          parseMethod: TANCampaignStatsParser().campaignStatsFromDictionary) as? CampaignStats {
            stats = statsObject
        }
        var specifics: CampaignSpecifics?
        if let specificsObject = parsedObject(campaignID: campaignID,
                                              jsonDictionary: jsonDictionary[CampaignKeys.specifics],
                                              objectClassString: String(describing: CampaignSpecifics.self),
                                              parseMethod: TANCampaignSpecificsParser().campaignSpecificsFromDictionary) as? CampaignSpecifics {
            specifics = specificsObject
        }
        var limits: CampaignLimits?
        if let limitsObject = parsedObject(campaignID: campaignID,
                                           jsonDictionary: jsonDictionary[CampaignKeys.limits],
                                           objectClassString: String(describing: CampaignLimits.self),
                                           parseMethod: TANCampaignLimitsParser().campaignLimitsFromDictionary) as? CampaignLimits {
            limits = limitsObject
        }
        var targets: CampaignTargets?
        if let targetsObject = parsedObject(campaignID: campaignID,
                                            jsonDictionary: jsonDictionary[CampaignKeys.targets],
                                            objectClassString: String(describing: CampaignTargets.self),
                                            parseMethod: TANCampaignTargetsParser().campaignTargetsFromDictionary) as? CampaignTargets {
            targets = targetsObject
        }
        var scheduler: CampaignScheduler?
        if let scheduleDictionary = scheduleDictionary {
            do {
                scheduler = try TANCampaingSchedulerParser().campaignSchedule(jsonDictionary: scheduleDictionary, campaignID: campaignID)
            } catch SerializationError.missing(let value) {
                throw SerializationError.missing(value)
            }
        }
        // first we need to fetch that campaign maybe it exist and if not create a new record
        if let campaign = campaignManagedObjectObject(campaignID: campaignID) {
            campaign.campaignID = campaignID
            campaign.name = name
            campaign.trigger = trigger
            campaign.category = category
            campaign.status = status
            campaign.version = version
            campaign.stats = stats
            campaign.content = content
            campaign.specifics = specifics
            campaign.limits = limits
            campaign.targets = targets
            campaign.scheduler = scheduler
            
            return campaign
        }
        
        return nil
    }
    
    private func campaignManagedObjectObject(campaignID: String) -> Campaign? {
        var campaign: Campaign?
        if let fetchedCampaign = TANPersistanceManager.sharedInstance.campaignDBManager.fetchCampaign(campaignID: campaignID) {
            campaign = fetchedCampaign
        } else if let newCampaign = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: Campaign.self)) as? Campaign {
            campaign = newCampaign
        }
        
        return campaign
    }
 }
 
 internal func parsedObject(campaignID: String, jsonDictionary: Any?, objectClassString: String, parseMethod: (JSONDictionary,String) throws -> NSManagedObject?) -> NSManagedObject? {
    guard jsonDictionary != nil else {
        return nil
    }
    var object: NSManagedObject?
    if let objectDictionary = jsonDictionary  as? JSONDictionary {
        do {
            object = try parseMethod(objectDictionary, campaignID)
        } catch SerializationError.missing(let value) {
            dLogDebug(message: "\(value) from \(objectClassString) dictionary is missing but is optional")
        } catch {
            dLogError(message: "Error on parsing")
        }
    } else {
        dLogDebug(message: "\(objectClassString) dictionary is missing but is optional")
    }
    
    return object
 }
