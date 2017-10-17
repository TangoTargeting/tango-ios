//
//  TANDBCampaignManager.swift
//  Tango
//
//  Created by Raul Hahn on 17/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

enum CampaignTrigger: String {
    case push = "push"
    case scheduler = "scheduler"
    case customTrigger = "ct"
    case location = "location"
    case undefined = "undefined"
}

class TANDBCampaignManager {
    var campaigns: [Campaign] = []
    private var locationCampaigns: [Campaign] = []
    private var scheduledCampaigns: [Campaign] = []

    private let campaignParser = TANCampaignParser()
    
    init() {}
    
    func saveCampaignsFrom(dictionary: JSONDictionary) {
    if let campaignsArray = dictionary["data"] as? Array<JSONDictionary> {
            //TODO:HR REmove this READING FROM FILEEEE
//        if let fileJson = readJSONFromFile(fileName: "campaignJSON", fileExtension: "json") as? JSONDictionary {
//            if let campaignsArray = fileJson["data"] as? Array<JSONDictionary> {
                let campaignsArrayParsed = campaignParser.campaignsFromArray(responseArray: campaignsArray)
                if areNewCampaigns(arrivingCampaigns: campaignsArrayParsed) {
                    campaigns = campaignsArrayParsed
                    updateLocationCampaigns()
                    updateScheduledCampaigns()
                    
                    TANPersistanceManager.sharedInstance.coreData.saveMainContext()
                }
            //}
        }
    }
    
    func saveCampaign(dictionary: JSONDictionary) {
        if let campaignID = dictionary[CampaignKeys.id] as? String {
            if fetchCampaign(campaignID: campaignID) == nil {
                do {
                    if let campaignParsed = try campaignParser.campaignFromDictionary(jsonDictionary: dictionary) {
                        campaigns.append(campaignParsed)
                        updateLocationCampaigns()
                        updateScheduledCampaigns()
                        
                        TANPersistanceManager.sharedInstance.coreData.saveMainContext()
                    }
                } catch {
                    dLogError(message: "Failed to parse Campaign")
                }
            }
            
        }
    }
    
    private func updateLocationCampaigns() {
        let locationCampaigns = self.campaigns.filter({$0.trigger == CampaignTrigger.location.rawValue})
        if locationCampaigns.count > 0 {
            self.locationCampaigns = locationCampaigns
            TANLocationManager.sharedInstance.processLocationCampaigns(campaigns:locationCampaigns)
        }
    }
    
    private func updateScheduledCampaigns() {
        let scheduledCampaigns = self.campaigns.filter({$0.trigger == CampaignTrigger.scheduler.rawValue})
        if scheduledCampaigns.count > 0 {
            self.scheduledCampaigns = scheduledCampaigns
            TANSchedulerManager.sharedInstance.processSchedulerCampaigns(campaigns: scheduledCampaigns)
        }
    }
    
    private func areNewCampaigns(arrivingCampaigns: [Campaign]) -> Bool {
        for (_, value) in arrivingCampaigns.enumerated() {
            let filterResult = self.campaigns.filter {
                $0.campaignID != value.campaignID
            }
            if self.campaigns.count == 0 || filterResult.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    func fetchCampaignForTriggerKey(triggerKey: String) -> Campaign? {
        var triggeredCampaign: Campaign?
        let result = TANPersistanceManager.sharedInstance.coreData.fetchRecordsFor(entityName:String(describing: Campaign.self),
                                                                                  predicate: NSPredicate(format: "trigger == %@", triggerKey))
        if result.count == 1 {
            if let campaign = result.first as? Campaign {
                triggeredCampaign = campaign
            }
        }
        
        return triggeredCampaign
    }
    
    func fetchCampaign(campaignID: String) -> Campaign? {
        return TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName:String(describing: Campaign.self),
                                                                         predicate: NSPredicate(format: "campaignID == %@", campaignID)) as? Campaign
    }
    
    func fetchCampaignsLocations() -> [CampaignTargetsLocations]? {
        return TANPersistanceManager.sharedInstance.coreData.fetchRecordsFor(entityName:  String(describing: CampaignTargetsLocations.self)) as? [CampaignTargetsLocations]
    }
    
    func fetchAllCampaigns() -> [Campaign]? {
        return TANPersistanceManager.sharedInstance.coreData.fetchRecordsFor(entityName: String(describing: Campaign.self)) as? [Campaign]
    }
    
    func deleteEvents(eventsUUID: [String]) {
        if let allEvents = TANPersistanceManager.sharedInstance.coreData.fetchRecordsFor(entityName: String(describing: CampaignEvent.self)) as? [CampaignEvent] {
            var eventsToRemove: [CampaignEvent] = []
            for (_, eventUUID) in eventsUUID.enumerated() {
                eventsToRemove.append(contentsOf: allEvents.filter({ (event) -> Bool in
                    return event.eventUUID == eventUUID
                }))
            }
            dLogInfo(message: "delete events: \(eventsToRemove)")
            TANPersistanceManager.sharedInstance.coreData.deleteObjects(managedObjects: eventsToRemove)
        }
    }
}


