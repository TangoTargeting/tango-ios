//
//  TANCampaignMediaHelper.swift
//  Tango
//
//  Created by Raul Hahn on 1/9/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

struct MediaKeys {
    static let size = "size"
    static let width = "width"
    static let height = "height"
    static let source = "src"
    static let media = "media"
    static let type = "type"
}

class TANCampaignMediaParser {
    func campaignMedia(jsonDictionary: JSONDictionary, campaignID: String) throws -> CampaignMedia? {
        do {
            let media = try mediaValidated(jsonDictionary)
            if let campaignMedia = campaignMedia(campaignID: campaignID) {
                campaignMedia.size = media.size
                campaignMedia.source = media.source
                campaignMedia.type = media.type
                
                if let url = URL(string: media.source) {
                    data(url:url, completion: { (data, response, error) in
                        if error != nil {
                            dLogInfo(message: "Failed to download image with source: \(media.source)")
                        }
                        if let mediaData = data {
                            campaignMedia.imageData = (mediaData as NSData)
                        }
                    })
                }
                
                return campaignMedia
            }
        } catch SerializationError.missing(let value) {
            throw SerializationError.missing(value)
        }
        
        return nil
    }
    
    private func mediaValidated(_ jsonDictionary: JSONDictionary) throws -> (source: String, type: String, size: CampaignMediaSize?) {
        guard let source = jsonDictionary[MediaKeys.source] as? String else {
            throw SerializationError.missing("source url")
        }
        guard let type = jsonDictionary[MediaKeys.type] as? String else {
            throw SerializationError.missing("media type")
        }
        guard let sizeDictionary = jsonDictionary[MediaKeys.size] as? JSONDictionary else {
            throw SerializationError.missing("size")
        }
        var mediaSize: CampaignMediaSize?
        do {
            mediaSize = try TANCamapaignMediaSizeParser().mediaSize(jsonDictionary: sizeDictionary)
        } catch SerializationError.missing(let value) {
            throw SerializationError.missing(value)
        }
        
        return (source, type, mediaSize)
    }
    
    private func campaignMedia(campaignID: String) -> CampaignMedia? {
        var media: CampaignMedia?
        if let fetchedMedia = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName:String(describing: CampaignMedia.self),
                                                                                        predicate: NSPredicate(format: "content.campaign.campaignID == %@", campaignID)) as? CampaignMedia {
            media = fetchedMedia
        } else if let newMedia = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignMedia.self)) as? CampaignMedia {
            media = newMedia
        }
        
        return media
    }
}

class TANCamapaignMediaSizeParser {
    func mediaSize(jsonDictionary: JSONDictionary) throws -> CampaignMediaSize? {
        do {
            let media = try sizeValidated(jsonDictionary)
            if let mediaSize = sizeFromDB(width: media.width, height: media.height) {
                mediaSize.width = media.width
                mediaSize.height = media.height
                
                return mediaSize
            }
        } catch SerializationError.missing(let value) {
            throw SerializationError.missing(value)
        }
        
        return nil
    }
    
    private func sizeValidated(_ jsonDictionary: JSONDictionary) throws -> (width: Float, height: Float) {
        guard let width = jsonDictionary[MediaKeys.width] as? Float else {
            throw SerializationError.missing("width")
        }
        guard let height = jsonDictionary[MediaKeys.height] as? Float else {
            throw SerializationError.missing("height")
        }
        
        return (width, height)
    }
    
    private func sizeFromDB(width: Float, height: Float) -> CampaignMediaSize? {
        var size: CampaignMediaSize?
        if let fetchedSize = TANPersistanceManager.sharedInstance.coreData.fetchRecord(entityName:String(describing: CampaignMediaSize.self),
                                                                                       predicate: NSPredicate(format: "sizeID == %@",sizeId(width: width, height: height))) as? CampaignMediaSize {
            size = fetchedSize
        } else if let newSize = TANPersistanceManager.sharedInstance.coreData.createManagedObjectForClassName(entityName: String(describing: CampaignMediaSize.self)) as? CampaignMediaSize {
            newSize.sizeID = sizeId(width: width, height: height)
            size = newSize
        }
        
        return size
    }
    
    private func sizeId(width:Float, height: Float) -> String {
        return "\(Int(width))\(Int(height))"
    }
}

extension CampaignMedia: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            return [MediaKeys.source, MediaKeys.type, MediaKeys.size]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        if key == MediaKeys.source {
            return self.source as AnyObject
        }
        if key == MediaKeys.type {
            return self.type as AnyObject
        }
        if key == MediaKeys.size {
            return self.size as AnyObject
        }
        
        return nil
    }
}

extension CampaignMediaSize: TANJSONEncodable {
    var jsonProperties: Array<String> {
        get {
            return [MediaKeys.width, MediaKeys.height]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        if key == MediaKeys.width {
            return self.width as AnyObject
        }
        if key == MediaKeys.height {
            return self.height as AnyObject
        }
        
        return nil
    }
}
