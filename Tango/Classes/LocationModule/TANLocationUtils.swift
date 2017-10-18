//
//  TANLocationUtils.swift
//  Tango
//
//  Created by Raul Hahn on 1/16/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation
import CoreLocation

let maxNumberOfRegions:Int = 20
let regionIdentifierDelimitator = "||"

func sortedDistances(currentLocation: CLLocation, allLocations: [CampaignTargetsLocations]) -> [CLLocationDistance] {
    var distances: [CLLocationDistance] = []
    for(_, campaignLocation) in allLocations.enumerated() {
        let location = CLLocation(latitude: campaignLocation.latitude, longitude: campaignLocation.longitude)
        let distanceFromCurrentLocation = location.distance(from: currentLocation)
        distances.append(distanceFromCurrentLocation)
    }
    
    return distances.sorted()
}

func maxAvailableDistance(distances: [CLLocationDistance]) -> CLLocationDistance? {
    // we can monitor only 20 locations so we will choose the 20 nearest
    if distances.count >= maxNumberOfRegions {
        return distances[maxNumberOfRegions - 1]
    } else {
        if let lastDistance = distances.last {
            return lastDistance
        }
    }
    
    return nil
}

// Identifier format: campaignId|| Components:..blabla
func campaignForRegionIdentifier(identifier: String) -> Campaign? {
    guard let separatorRange = identifier.range(of: regionIdentifierDelimitator) else { return nil }
    
    #if swift(>=4.0)
    let campaignID = String(identifier[..<separatorRange.lowerBound])
    #else
    let campaignID = identifier.substring(with: Range<String.Index>.init(uncheckedBounds: (lower: identifier.startIndex, upper: separatorRange.lowerBound)))
    #endif
    
    return TANPersistanceManager.sharedInstance.campaignDBManager.fetchCampaign(campaignID: campaignID)
}

func isOnExitTrigger(identifier: String) -> Bool {
    guard let location = location(identifier: identifier), location.onExit else { return false }
    return true
}

func isOnEnterTrigger(identifier: String) -> Bool {
    guard let location = location(identifier: identifier), location.onEnter else { return false }
    return true
}

func isOnStayTrigger(identifier: String) -> Bool {
    guard let location = location(identifier: identifier), location.isOnStayTrigger() else { return false }
    return true
}

func location(identifier: String) -> CampaignTargetsLocations? {
    return TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName: String(describing: CampaignTargetsLocations.self), predicate: NSPredicate(format: "locationID == %@", identifier)) as? CampaignTargetsLocations
}

extension CampaignTargetsLocations {
    func isOnStayTrigger() -> Bool {
        return !onEnter && !onExit && onStay > 0
    }
    
    func isOnEnterTriger() -> Bool {
        return onEnter
    }
    
    func isOnExitTriger() -> Bool {
        return onExit
    }
}
