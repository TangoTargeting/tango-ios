//
//  TANCampaignStatsHelper.swift
//  Tango
//
//  Created by Raul Hahn on 23/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

struct CampaignStatsKeys {
    static let events = "events"
}

class TANCampaignStatsParser {
    func campaignStatsFromDictionary(jsonDictionary: JSONDictionary, campaignID:String) throws -> CampaignStats? {
        // stats dictionary should be something like this:
/*
        stats: {
         events: [
            {   type: close,
                timestamp: 2314324123
            },
            {   type: open,
                timestamp: 2314324123
            },
         ]
        }
*/
        
        
//        if let campaignStats = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignStats.self)) as? CampaignStats {
//            
//            return campaignStats
//        }

        return nil
    }
}
