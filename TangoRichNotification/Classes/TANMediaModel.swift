//
//  TANMediaModel.swift
//  TangoDevAppSwift
//
//  Created by Raul Hahn on 12/16/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

enum MediaType: String {
    case jpg = "jpg"
    case jpeg = "jpeg"
    case png = "png"
    case gif = "gif"
    case video = "video"
    case noMedia = "noMedia"
}

@available(iOS 10.0, *)
struct Media {
    private var data: Data
    private var ext: String
    private var type: MediaType
    
    init(forMediaType mediaType: MediaType, withData data: Data, fileExtension ext: String) {
        self.type = mediaType
        self.data = data
        self.ext = ext
    }
    
    var attachmentOptions: [String: Any] {
        switch(self.type) {
        case .jpg, .jpeg, .png, .noMedia:
            return [UNNotificationAttachmentOptionsThumbnailClippingRectKey: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.50).dictionaryRepresentation]
        case .gif:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        case .video:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
            //        case .audio:
            //            return [UNNotificationAttachmentOptionsThumbnailHiddenKey: 1]
        }
    }
    
    var fileIdentifier: String {
        return self.type.rawValue
    }
    
    var fileExt: String {
        if self.ext.characters.count > 0 {
            return self.ext
        } else {
            switch(self.type) {
            case .jpg:
                return "jpg"
            case .jpeg:
                return "jpeg"
            case .png:
                return "png"
            case .gif:
                return "gif"
            case .video:
                return "mp4"
            case .noMedia:
                return "noMedia"
            }
        }
    }
    
    var mediaData: Data? {
        return self.data
    }
    
    static func mediaSummary(userInfo: JSONDictionary) -> MediaSummary? {
        if let dataDictionary = userInfo[PayloadKeys.data] as? JSONDictionary {
            if let objectDictionary = dataDictionary[PayloadKeys.object] as? JSONDictionary {
                if let contentDictionary = objectDictionary[PayloadKeys.content] as? JSONDictionary {
                    if let mediaDictionary = contentDictionary[PayloadKeys.media] as? JSONDictionary {
                        if let urlSource = mediaDictionary[PayloadKeys.source] as? String,
                            let mediaTypeString = mediaDictionary[PayloadKeys.type] as? String {
                            if let mediaType = MediaType(rawValue: mediaTypeString) {
                                return (urlSource, mediaType)
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
}

func mediaTypeFromUrl(urlString: String) -> MediaType? {
    if let url  = URL(string: urlString) {
        switch url.pathExtension.lowercased() {
        case "jpg":
            return MediaType.jpg
        case "jpeg":
            return MediaType.jpeg
        case "png":
            return MediaType.png
        case "gif":
            return MediaType.gif
        case "mp4":
            return MediaType.video
        default:
            return nil
        }
    }
    
    return nil
}
