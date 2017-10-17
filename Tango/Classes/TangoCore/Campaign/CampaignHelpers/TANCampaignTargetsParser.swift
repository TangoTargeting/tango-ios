//
//  TANCampaignTargetsHelper.swift
//  Tango
//
//  Created by Raul Hahn on 24/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

struct TargetsKeys {
    static let locations = "locations"
    static let latitude = "lat"
    static let longitude = "long"
    static let meters = "meters"
    static let onEnter = "on_enter"
    static let onExit = "on_exit"
    static let onStay = "on_location_seconds"
}

struct TANLocation {
    var locationId = ""
    var lat: Double = 0
    var long: Double = 0
    var meters: Double = 0
    var onEnter = false
    var onExit = false
    var onStay: Int16 = 0
}

class TANCampaignTargetsParser {
    func campaignTargetsFromDictionary(jsonDictionary: JSONDictionary, campaignID: String) throws -> CampaignTargets? {
        guard let locationsArray = jsonDictionary[TargetsKeys.locations] as? Array<Any> else {
            throw SerializationError.missing("locations")
        }
        if let campaignTargets = campaignTargets(campaignID: campaignID) {
            do {
                let locations = try TANCampaignTargetsParser().locationsFromArray(responseArray: locationsArray, campaignID: campaignID)
                campaignTargets.addToLocations(NSSet.init(array: locations))
            } catch SerializationError.missing(let value) {
                throw SerializationError.missing(value)
            }
            
            return campaignTargets
        }
        
        return nil
    }
    
    private func campaignTargets(campaignID: String) -> CampaignTargets? {
        var campaignTargets: CampaignTargets?
        if let fetchedTargets = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignTargets.self), predicate: NSPredicate(format: "campaign.campaignID == %@", campaignID)) as? CampaignTargets {
            campaignTargets = fetchedTargets
        } else if let newTargets = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignTargets.self)) as? CampaignTargets {
            campaignTargets = newTargets
        }
        
        return campaignTargets
    }
    
    private func locationsFromArray(responseArray: Array<Any>, campaignID: String) throws -> [CampaignTargetsLocations] {
        var locations: [CampaignTargetsLocations] = []
        for (_, value) in responseArray.enumerated() {
            if let location = value as? JSONDictionary {
                guard let latitude = location[TargetsKeys.latitude] as? Double else {
                    throw SerializationError.missing("latitude")
                }
                guard let longitude = location[TargetsKeys.longitude] as? Double else {
                    throw SerializationError.missing("longitude")
                }
                guard let meters = location[TargetsKeys.meters] as? Double else {
                    throw SerializationError.missing("location radius")
                }
                guard let onExit = location[TargetsKeys.onExit] as? Bool else {
                    throw SerializationError.missing("location on Exit trigger")
                }
                guard let onEnter = location[TargetsKeys.onEnter] as? Bool else {
                    throw SerializationError.missing("location on Enter trigger")
                }
                guard let onStay = location[TargetsKeys.onStay] as? Int16 else {
                    throw SerializationError.missing("location on Stay trigger")
                }
                let location = TANLocation(locationId: locationIdentifier(campaignID: campaignID,
                                                                          latitude: latitude,
                                                                          longitude: longitude,
                                                                          meters: meters),
                                           lat: latitude,
                                           long: longitude,
                                           meters: meters,
                                           onEnter: onEnter,
                                           onExit: onExit,
                                           onStay: onStay)
                if let locationObject = campaignLocation(campaignID: campaignID, location: location) {
                    locations.append(locationObject)
                }
            }
        }
        
        return locations
    }
    
    private func campaignLocation(campaignID: String, location: TANLocation) -> CampaignTargetsLocations? {
        if let fetchedLocations = TANPersistanceManager.sharedInstance.coreData.fetchRecordsFor(entityName: String(describing: CampaignTargetsLocations.self), predicate: NSPredicate(format: "locationID == %@", locationIdentifier(campaignID: campaignID, latitude: location.lat, longitude: location.long, meters: location.meters))) as? [CampaignTargetsLocations] {
            if let firstLocation = fetchedLocations.first, fetchedLocations.count > 0 {
                setupLocation(location: firstLocation, locationConfig: location)
                
                return firstLocation
            }
        }
        if let newLocation = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignTargetsLocations.self)) as? CampaignTargetsLocations {
            setupLocation(location: newLocation, locationConfig: location)
            
            return newLocation
        }
        
        return nil
    }
    
    private func setupLocation(location: CampaignTargetsLocations, locationConfig: TANLocation) {
        location.latitude = locationConfig.lat
        location.longitude = locationConfig.long
        location.meters = locationConfig.meters
        location.locationID = locationConfig.locationId
        location.onStay = locationConfig.onStay
        location.onExit = locationConfig.onExit
        location.onEnter = locationConfig.onEnter
    }
    
    private func locationIdentifier(campaignID: String, latitude: Double, longitude: Double, meters: Double) -> String {
        let locationComponents = String(latitude).appending(String(longitude)).appending(String(meters))
        
        return campaignID.appending("\(regionIdentifierDelimitator) Components:\(locationComponents)")
    }
}
