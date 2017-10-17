//
//  DMBackgroundViewRenderer.swift
//  Tango
//
//  Created by Raul Hahn on 12/7/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

class DMBackgroundViewRenderer {
    private var content: DMDisplayContent
    
    init(content: DMDisplayContent) {
        self.content = content
    }
    
    func displayBackgroundView() {
        TANLocalNotificationComander().addLocalNotificationRequestForBackground(content: self.content)
    }
}
