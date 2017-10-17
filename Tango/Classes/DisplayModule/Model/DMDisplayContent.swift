//
//  DMDisplayContent.swift
//  Tango
//
//  Created by Raul Hahn on 12/6/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

enum DMCampaignMediaType: String {
    case jpg = "jpg"
    case jpeg = "jpeg"
    case gif = "gif"
    case noMedia = "noMedia"
    
    static func mediaType(receivedType: String?) -> DMCampaignMediaType {
        if let type = receivedType {
            switch type {
            case "jpg":
                return .jpg
            case "jpeg":
                return .jpeg
            case "gif":
                return .gif
            default:
                return .noMedia
            }
        }
        
        return .noMedia
    }
}

struct DMLabelContent {
    var text: String
    var textColor: UIColor
}

struct DMActionButtonContent {
    var buttonTitle: DMLabelContent
    var buttonAction: String
    var buttonBackgroundColor: UIColor
    
    init(campaignAction: CampaignAction) {
        let textColorHex = campaignAction.textColorHexARGB
        let buttonTitle = campaignAction.title ?? "Ok"
        let textColor = UIColor(hexString: textColorHex) ?? kDefaultAlertBodyTextColor
        self.buttonTitle = DMLabelContent(text: buttonTitle, textColor: textColor)
        self.buttonAction = campaignAction.uri ?? ""
        self.buttonBackgroundColor = UIColor(hexString: campaignAction.backgroundColorHexARGB) ?? UIColor.white
    }
}

struct DMDisplayContent {
    private var campaign: Campaign
    var titleLabel: DMLabelContent!
    var textLabel: DMLabelContent?
    var type: DMCampaignMediaType!
    var primaryButtonAction: DMActionButtonContent!
    var secondaryButtonAction: DMActionButtonContent?
    var imageUrl: String?
    var imageSize: CGSize?
    var image:UIImage?

    init(campaign: Campaign) {
        self.campaign = campaign
        // Required
        guard let title = campaign.content?.title else {
            dLogError(message: "Title is a required field for display content, and is nil")
            return
        }
        if let media = campaign.content?.media {
            self.type = DMCampaignMediaType.mediaType(receivedType: media.source)
            self.imageUrl = media.source
            let imageHeight: Float = media.size?.height ?? 250.0
            self.imageSize = CGSize(width: 300, height: Int(imageHeight))
            setImage(data: media.imageData)
        } else {
            self.type = .noMedia
        }
        guard let primaryButtonAction = campaign.content?.primaryAction else {
            dLogError(message: "primary button is a required field for display content, and is nil")
            return
        }
        self.primaryButtonAction = DMActionButtonContent(campaignAction: primaryButtonAction)
        if let secondaryButtonAction = campaign.content?.secondaryAction {
            self.secondaryButtonAction = DMActionButtonContent(campaignAction: secondaryButtonAction)
        }
        self.titleLabel = DMLabelContent(text: title, textColor: kDefaultAlertTitleColor)
        if let text = campaign.content?.body{
            self.textLabel = DMLabelContent(text: text, textColor: kDefaultAlertBodyTextColor)
        }
    }
    
    private mutating func setImage(data: NSData?) {
        if let data = data as Data? {
            if let image = UIImage(data: data) {
                self.image = image
            }
        }
    }
    
    @available(iOS 10.0, *)
    func notificationContent() -> UNMutableNotificationContent {
        return TANLocalNotificationComander().notificationContent(campaign: self.campaign)
    }
    
    func campaigID() -> String? {
        return self.campaign.campaignID
    }
    
}
