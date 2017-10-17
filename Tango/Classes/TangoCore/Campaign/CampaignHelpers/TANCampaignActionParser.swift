//
//  TANCampaignActionParser.swift
//  Tango
//
//  Created by Raul Hahn on 1/9/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

enum ActionType: String {
    case primary = "action_primary"
    case secondary = "action_secondary"
}

struct ActionKeys {
    static let title = "title"
    static let uri = "uri"
    static let type = "type"
    static let textColor = "text_color"
    static let backgorundColor = "background_color"
}

class TANCampaignActionParser {
    func campaignAction(jsonDictionary: JSONDictionary, campaignID: String, actionType: ActionType) throws -> CampaignAction? {
        do {
            let action = try actionValidated(jsonDictionary)
            if let campaignAction = campaignAction(campaignID: campaignID, actionType: actionType) {
                campaignAction.title = action.title
                campaignAction.type = action.type
                campaignAction.uri = action.uri
                campaignAction.textColorHexARGB = action.textColor
                campaignAction.backgroundColorHexARGB = action.backgroundColor

                return campaignAction
            }
        } catch SerializationError.missing(let value) {
            throw SerializationError.missing(value)
        }
        
        return nil
    }
    
    private func actionValidated(_ jsonDictionary: JSONDictionary) throws -> (title: String, type: String, uri: String, backgroundColor: String?, textColor: String?) {
        guard let title = jsonDictionary[ActionKeys.title] as? String else {
            throw SerializationError.missing("title from action object")
        }
        guard let uri = jsonDictionary[ActionKeys.uri] as? String else {
            throw SerializationError.missing("uri from action object")
        }
        guard let type = jsonDictionary[ActionKeys.type] as? String else {
            throw SerializationError.missing("type from action object")
        }
        var buttonBackgroundColor: String?
        if let colorArray = jsonDictionary[ActionKeys.backgorundColor] as? Array<Float> {
            buttonBackgroundColor = hexARGBString(rgbaArray: colorArray)
        }
        var textColor: String?
        if let textColorArray = jsonDictionary[ActionKeys.textColor] as? Array<Float> {
            textColor = hexARGBString(rgbaArray: textColorArray)
        }
    
        return (title, type, uri, buttonBackgroundColor, textColor)
    }

    private func campaignAction(campaignID: String, actionType: ActionType) -> CampaignAction? {
        var action: CampaignAction?
        var fetchPredicateFormat = "primaryContent.campaign.campaignID == %@"
        if  actionType == .secondary {
            fetchPredicateFormat = "secondaryContent.campaign.campaignID == %@"
        }
        if let fetchedAction = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName:String(describing: CampaignAction.self),
                                                                                         predicate: NSPredicate(format: fetchPredicateFormat, campaignID)) as? CampaignAction {
            action = fetchedAction
        } else if let newAction = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignAction.self)) as? CampaignAction {
            action = newAction
        }
        
        return action
    }
}

typealias TANConfigColor = (red: Float, green: Float, blue: Float, alpha: Float)

enum ConfigElement {
    case text
    case buttonBackground
}

extension CampaignAction: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            return [ActionKeys.title, ActionKeys.uri, ActionKeys.type, ActionKeys.textColor, ActionKeys.backgorundColor]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        if key == ActionKeys.title {
            return self.title as AnyObject
        }
        if key == ActionKeys.uri {
            return self.uri as AnyObject
        }
        if key == ActionKeys.type {
            return self.type as AnyObject
        }
        if key == ActionKeys.textColor {
           return colorArrayRGBA(hexARGB: self.textColorHexARGB) as AnyObject
        }
        if key == ActionKeys.backgorundColor {
            return colorArrayRGBA(hexARGB: self.backgroundColorHexARGB) as AnyObject
        }
        
        return nil
    }
}
