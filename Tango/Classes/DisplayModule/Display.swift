//
//  Display.swift
//  Tango
//
//  Created by Raul Hahn on 12/5/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

class Display {
    func displayCampaign(campaign: Campaign) {
        DMDisplayManager(campaign: campaign)?.displayCampaign()
    }
}
