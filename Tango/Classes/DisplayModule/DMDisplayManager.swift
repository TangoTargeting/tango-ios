//
//  DMDisplayManager.swift
//  Tango
//
//  Created by Raul Hahn on 12/5/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

// We add a different prefix here for classes because we want to use this as a sepparate framework
final class DMDisplayManager {
   // static let sharedInstance = DMDisplayManager()
    private var campaign: Campaign
    private var eventsHandler: EventsHandler
    
    init?(campaign: Campaign) {
        self.campaign = campaign
        
        guard let campaignID = campaign.campaignID else {
            dLogError(message: "Campaign id is nil")
            
            return nil
        }
        self.eventsHandler = EventsHandler(campaignId: campaignID)
    }
    
    func displayCampaign() {
        if isCampaignActive(campaign: self.campaign) == true {
            let content = DMDisplayContent(campaign: self.campaign)
            if isAppInBackground() == false {
                DMForegroundViewController(content: content, eventsHandler: eventsHandler).presentModalViewController()
            } else {
                DMBackgroundViewRenderer(content: content).displayBackgroundView()
            }
        }
    }
}
