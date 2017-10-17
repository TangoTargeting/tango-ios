//
//  CustomTrigger.swift
//  Tango
//
//  Created by Raul Hahn on 23/12/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import UIKit

class CustomTrigger {
    class func trigger(triggerKey: String) {
        triggerCampaign(triggerKey: triggerKey)
    }
    
    private class func triggerCampaign(triggerKey: String) {
        let customTriggerPrefix = "ct_"
        var ctTriggerKey: String
        if triggerKey.hasPrefix(customTriggerPrefix) {
            ctTriggerKey = triggerKey
        } else {
            ctTriggerKey = customTriggerPrefix.appending(triggerKey)
        }
        if let campaign = TANPersistanceManager.sharedInstance.campaignDBManager.fetchCampaignForTriggerKey(triggerKey: ctTriggerKey) {
            // send campaign to display manager
            Display().displayCampaign(campaign: campaign)
        }
    }
}
