//
//  TANEvents.swift
//  Tango
//
//  Created by Raul Hahn on 2/27/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

enum EventType: String {
    case close = "CAMPAIGN_CLOSE"
    case display = "CAMPAIGN_DISPLAY"
    case click = "CAMPAIGN_ACTION"
    case pushNotificationReceived = "PN_RECEIVED"
    case appOpen = "APP_OPEN"
    case appClose = "APP_CLOSE"
}

struct Event {
    var eventType: EventType
    var time: String
    var uuid: String
    
    init(type: EventType) {
        self.eventType = type
        self.time = Date().iso8601
        self.uuid = UUID().uuidString
    }
}

struct EventsHandler {
    private var campaignId: String
    
    init(campaignId: String) {
        self.campaignId = campaignId
    }
    
    func addEvent(event: Event) {
        if let fetchedCampaign = TANPersistanceManager.sharedInstance.campaignDBManager.fetchCampaign(campaignID: campaignId) {
            addStatsEvent(campaign: fetchedCampaign, event: event)
            addTotalsEvent(campaign: fetchedCampaign, eventType: event.eventType)
            TANPersistanceManager.sharedInstance.coreData.saveMainContext()
            dLogInfo(message:"event added to DB: \(event)")
        } else {
            dLogInfo(message: "event was not added to DB")
        }
    }
    
    private func addStatsEvent(campaign: Campaign, event: Event) {
        if let campaignEvent = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignEvent.self), predicate: NSPredicate(format: "eventUUID == %@", event.uuid)) as? CampaignEvent {
            dLogInfo(message: "we try to add an event that already exist \(String(describing: campaignEvent.eventUUID))")
        } else if let campaignEvent = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignEvent.self)) as? CampaignEvent {
            campaignEvent.type = event.eventType.rawValue
            campaignEvent.timestamp = event.time
            campaignEvent.eventUUID = event.uuid
            if let camapaignStats = campaign.stats {
                camapaignStats.addToEvents(campaignEvent)
            } else if let newCampaignStats = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignStats.self)) as? CampaignStats {
                newCampaignStats.addToEvents(campaignEvent)
                campaignEvent.campaignStats = newCampaignStats
                campaign.stats = newCampaignStats
            }
        }
    }
    
    private func addTotalsEvent(campaign: Campaign, eventType: EventType) {
        if let fetchedTotals = campaign.totalEvents {
            setupTotals(totalsEvent: fetchedTotals, eventType: eventType)
        } else if let newTotals = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing:CampaignTotalEvents.self)) as? CampaignTotalEvents {
            setupTotals(totalsEvent: newTotals, eventType: eventType)
            campaign.totalEvents = newTotals
        }
    }
    
    private func setupTotals(totalsEvent: CampaignTotalEvents, eventType: EventType) {
        switch eventType {
        case .close:
            totalsEvent.totalClose = totalsEvent.totalClose + 1
            break
        case .click:
            totalsEvent.totalClicks = totalsEvent.totalClicks + 1
            break
        case .display:
            totalsEvent.totalDisplay = totalsEvent.totalDisplay + 1
            break
        default:
            return
        }
    }
    
    func addEvents(events: [Event]) {
        for (_, event) in events.enumerated() {
            addEvent(event: event)
        }
    }
}

struct EventKeys {
    static let deviceID = "source_uid"
    static let eventUid = "event_uid"
    static let timestamp = "timestamp" // ISO8601
    static let eventType = "event_name"
    static let campaignID = "campaign_id"
}

func encodedEvent(event: CampaignEvent) -> JSONDictionary? {
    var encodedEvent: JSONDictionary = [:]
    let deviceUid = registeredID()
    if deviceUid.isEmpty == true {
        return nil
    }
    guard let eventUid = event.eventUUID else {
        return nil
    }
    guard let timestamp = event.timestamp else {
        return nil
    }
    guard let eventType = event.type else {
        return nil
    }
    
    encodedEvent[EventKeys.deviceID] = deviceUid as AnyObject?
    encodedEvent[EventKeys.eventUid] = eventUid as AnyObject?
    encodedEvent[EventKeys.timestamp] = timestamp as AnyObject?
    encodedEvent[EventKeys.eventType] = eventType as AnyObject?
    if let campaignId = event.campaignStats?.campaign?.campaignID {
        encodedEvent[CampaignKeys.data] = [EventKeys.campaignID : campaignId] as AnyObject?
    }
    
    return encodedEvent
}
