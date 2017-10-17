//
//  TANUserDefaultsHandler.swift
//  Tango
//
//  Created by Raul Hahn on 29/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

class TANPersistanceManager {    
    static let sharedInstance = TANPersistanceManager()
    let coreData = TANCoreDataStack()
    var campaignDBManager: TANDBCampaignManager = TANDBCampaignManager()
    
    private init () {
        if let storedCampaigns = coreData.fetchRecordsFor(entityName:String(describing: Campaign.self)) as? [Campaign] {
            campaignDBManager.campaigns = storedCampaigns
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TANPersistanceManager.appWillTerminate),
                                               name: Notification.Name.UIApplicationWillTerminate,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Private methods
    
//    private func setupLocationCampaigns(campaigns: [Campaign]) {
//        let locationCampaigns = campaigns.filter({$0.trigger == CampaignTrigger.location.rawValue})
////        if locationCampaigns.count > 0 {
//            let locationCampaignsVariable = Variable(locationCampaigns)
//            campaignDBManager.locationCampaigns = locationCampaignsVariable
//            TANLocationManager.sharedInstance.registerLocationCampaignObserver(observer: locationCampaignsVariable.asObservable())
////        }
//    }
//    
//    private func setupScheduledCampaigns(campaigns: [Campaign]) {
//        let scheduledCampaigns = campaigns.filter({$0.trigger == CampaignTrigger.scheduler.rawValue})
//        if scheduledCampaigns.count > 0 {
//            let scheduledCampaignsVariable = Variable(scheduledCampaigns)
//            campaignDBManager.scheduledCampaigns = scheduledCampaignsVariable
//            TANSchedulerManager.sharedInstance.registerSchedulerCampaignObserver(observer: scheduledCampaignsVariable.asObservable())
//        }
//    }
    
    // MARK: UIApplicationDelegate
    
    @objc func appWillTerminate() {
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreData.saveMainContext()
    }
}
