//
//  Extensions.swift
//  TangoDevAppSwift
//
//  Created by Raul Hahn on 12/16/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
extension UNNotificationAttachment {
    static func create(fromMedia media: Media) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileIdentifier = "\(media.fileIdentifier).\(media.fileExt)"
            let fileURL = tmpSubFolderURL.appendingPathComponent(fileIdentifier)
            
            guard let data = media.mediaData else {
                return nil
            }
            
            try data.write(to: fileURL)
            return self.create(fileIdentifier: fileIdentifier, fileUrl: fileURL, options: media.attachmentOptions)
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
    
    private static func create(fileIdentifier: String, fileUrl: URL, options: [String : Any]? = nil) -> UNNotificationAttachment? {
        var attachment: UNNotificationAttachment?
        do {
            attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileUrl, options: options)
        } catch {
            print("error " + error.localizedDescription)
        }
        
        return attachment
    }
}

@available(iOS 10.0, *)
func loadAttachment(forMediaType mediaType: MediaType,
                    withUrlString urlString: String,
                    completionHandler: ((UNNotificationAttachment?) -> Void)) {
    guard let url = resourceURL(forUrlString: urlString) else {
        completionHandler(nil)
        return
    }
    
    do {
        let data = try Data(contentsOf: url)
        let media = Media(forMediaType: mediaType, withData: data, fileExtension: url.pathExtension)
        if let attachment = UNNotificationAttachment.create(fromMedia: media) {
            completionHandler(attachment)
            return
        }
        completionHandler(nil)
    } catch {
        print("error " + error.localizedDescription)
        completionHandler(nil)
    }
}
