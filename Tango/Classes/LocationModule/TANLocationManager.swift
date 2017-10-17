//
//  TANLocationManager.swift
//  Tango
//
//  Created by Raul Hahn on 1/12/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation
import CoreLocation

struct LocationTimer {
    var locationId: String
    var timer: Timer
}

extension LocationTimer: Equatable {
    static func ==(first: LocationTimer, second: LocationTimer) -> Bool {
        return first.locationId == second.locationId
    }
}

class TANLocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = TANLocationManager()
    private let kLocationIdKey = "locationID"
    private var locationManager: CLLocationManager = CLLocationManager()
    private var onStayTimers: [LocationTimer] = []
    
    private override init(){
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
    }
    
    var lastKnowLocationCoordinate: CLLocationCoordinate2D?
    private(set) var locationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: Internal methods
    
    func processLocationCampaigns(campaigns: [Campaign]) {
        if campaigns.count > 0 {
            startMonitoringCampaignRegions()
        }
    }
    
    func startListeningLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    func stopListeningLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func requestAlwaysAuthorization() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func isLocationServiceEnable() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    // MARK: Pivate methods 
    
    private func startMonitoringCampaignRegions() {
        if locationStatus == .authorizedAlways {
            if let storedRegions = TANPersistanceManager.sharedInstance.campaignDBManager.fetchCampaignsLocations() {
                if storedRegions.count > 0 {
                    let circRegions = circularRegions(campaignLocations: storedRegions)
                    if areRegionsAlreadyMonitored(newRegions: circRegions) {
                        return
                    }
                    if circRegions.count + locationManager.monitoredRegions.count <= maxNumberOfRegions {
                        startMonitoring(regions: circRegions)
                    } else {
                        let closestRegions = circularRegions(campaignLocations: nearestRegions(allRegions: storedRegions))
                        updateMonitoredRegions(newRegions: closestRegions)
                    }
                }
            }
        }
    }
    
    private func areRegionsAlreadyMonitored(newRegions: [CLCircularRegion]) -> Bool {
        var notMonitoredRegions: [CLCircularRegion] = []
        if let monitoredRegions = Array(locationManager.monitoredRegions) as? [CLCircularRegion] {
            for (_, newRegion) in newRegions.enumerated() {
                if monitoredRegions.contains(newRegion) == false {
                    notMonitoredRegions.append(newRegion)
                }
            }
        }
        
        return notMonitoredRegions.count == 0
    }
    
    private func startMonitoring(regions: [CLCircularRegion]) {
        for (_, region) in regions.enumerated() {
            self.locationManager.startMonitoring(for: region)
        }
    }
    
    private func stopMonitoring(regions: [CLRegion]) {
        
    }
    
    // return nearest 20 regions from all regions.
    private func nearestRegions(allRegions: [CampaignTargetsLocations]) -> [CampaignTargetsLocations] {
        var nearestRegions: [CampaignTargetsLocations] = []
        if let lastLocationCoordinate = lastKnowLocationCoordinate {
            let lastKnownLocation = CLLocation(latitude: lastLocationCoordinate.latitude, longitude: lastLocationCoordinate.longitude)
            let distances: [CLLocationDistance] = sortedDistances(currentLocation: lastKnownLocation, allLocations: allRegions)
            let maxDistance = maxAvailableDistance(distances: distances)
            for (_, campaignLocation) in allRegions.enumerated() {
                let location = CLLocation(latitude: campaignLocation.latitude, longitude: campaignLocation.longitude)
                let distance =  location.distance(from: lastKnownLocation)
                if let maxAvailableDistance = maxDistance {
                    if distance <= maxAvailableDistance {
                        nearestRegions.append(campaignLocation)
                    }
                }
            }
        }
        
        return nearestRegions
    }
    
    private func updateMonitoredRegions(newRegions: [CLCircularRegion]) {
        let monitoredRegions = Array(locationManager.monitoredRegions)
        stopMonitoring(regions: monitoredRegions)
        for (_, region) in newRegions.enumerated() {
            locationManager.startMonitoring(for: region)
        }
    }
    
    // MARK: Location manager delegate methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .authorizedWhenInUse:
            self.locationManager.requestAlwaysAuthorization()
            return
        case .authorizedAlways:
            self.locationManager.startMonitoringSignificantLocationChanges()
            self.startMonitoringCampaignRegions()

            return
        case .denied, .restricted:
             //TODO:HR Maybe show an alert if there is no authorization.
            
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastCoordinate = locations.last?.coordinate {
            lastKnowLocationCoordinate  = lastCoordinate
        }
        dLogLocationInfo(message: "updatedLocation -> latitude = \(String(describing: lastKnowLocationCoordinate?.latitude)), logitude = \(String(describing: lastKnowLocationCoordinate?.longitude))")
        
        // trigger new get campaign. Maybe there are new campaign for this location
        TANApiHandler().syncCampaigns { [weak self] (error) in
            if error != nil {
                dLogError(message: "there was an error syncing campaings when location update: \(String(describing: error?.localizedDescription))")
            }
            self?.startMonitoringCampaignRegions() // We need to update monitored regions.
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        dLogError(message: "Location manager did fail with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
        dLogLocationInfo(message: "User start monitoring for region: \(region.description)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        dLogLocationInfo(message: "User did enter region: \(region.description)")
        if isOnEnterTrigger(identifier: region.identifier) {
            if let campaign = campaignForRegionIdentifier(identifier: region.identifier) {
                DMDisplayManager(campaign: campaign)?.displayCampaign()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        dLogLocationInfo(message: "User did exit region: \(region.description)")
        if isOnExitTrigger(identifier: region.identifier) {
            if let campaign = campaignForRegionIdentifier(identifier: region.identifier) {
                DMDisplayManager(campaign: campaign)?.displayCampaign()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        // add check for user already in the region.
        if let location = location(identifier: region.identifier) {
            if location.isOnStayTrigger() {
                if state == .inside {
                    addLocationTimer(identifier: region.identifier, location: location)
                }
                if state == .outside {
                    removeLocationTimer(identifier: region.identifier)
                }
            }
        }
    }
    
    private func addLocationTimer(identifier: String, location: CampaignTargetsLocations) {
        let timer = Timer.scheduledTimer(timeInterval: TimeInterval(location.onStay), target: self, selector: #selector(TANLocationManager.triggerTimerAction(timer:)), userInfo: [kLocationIdKey:identifier], repeats: false)
        if !onStayTimers.contains(LocationTimer(locationId: identifier, timer: timer)) {
            onStayTimers.append(LocationTimer(locationId: identifier, timer: timer))
        }
    }
    
    private func removeLocationTimer(identifier: String) {
        let timer = onStayTimers.filter({ (locationTimer) -> Bool in
            return locationTimer.locationId == identifier
        })
        var timersToRemove: [LocationTimer] = []
        for (_, locationTimer) in timer.enumerated() {
            locationTimer.timer.invalidate()
            timersToRemove.append(locationTimer)
        }
        removeLocationTimers(timers: timersToRemove)
    }
    
    private func removeLocationTimers(timers: [LocationTimer]) {
        for (_, timer) in timers.enumerated() {
            if let index = onStayTimers.index(of: timer) {
                onStayTimers.remove(at: index)
            }
        }
    }
    
    @objc func triggerTimerAction(timer: Timer) {
        if let locationIdentifier = (timer.userInfo as? [String:String])?[kLocationIdKey] {
            if let campaign = campaignForRegionIdentifier(identifier: locationIdentifier) {
                DMDisplayManager(campaign: campaign)?.displayCampaign()
            }
        }
    }

}

func circularRegions(campaignLocations: [CampaignTargetsLocations]) -> [CLCircularRegion] {
    var circurlarRegions: [CLCircularRegion] = []
    for (_, location) in campaignLocations.enumerated() {
        if let regionIdentifier = location.locationID {
            circurlarRegions.append(CLCircularRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                                     radius: location.meters,
                                                     identifier: regionIdentifier))
        }
    }
    
    return circurlarRegions
}
