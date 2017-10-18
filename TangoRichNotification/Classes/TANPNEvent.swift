//
//  TANPNEvent.swift
//  TangoDevAppSwift
//
//  Created by Raul Hahn on 22/03/17.
//  Copyright © 2017 Tangotargetting. All rights reserved.
//

import Foundation

internal struct EventKeys {
    static let deviceID = "source_uid"
    static let eventUid = "event_uid"
    static let timestamp = "timestamp" // ISO8601
    static let eventType = "event_name"
    static let campaignID = "campaign_id"
}

internal enum EventType: String {
    case click = "CAMPAIGN_ACTION"
    case pushNotificationReceived = "PN_RECEIVED"
}

private func pushNotifEventReceiveJSON(payload: JSONDictionary) -> [JSONDictionary]? {
    if let campaignID = campaignID(payload: payload) {
        let eventUUID = UUID().uuidString
        let timestamp = Date().iso8601
        let eventType = EventType.pushNotificationReceived.rawValue
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            let eventJSON: JSONDictionary = [EventKeys.deviceID : deviceID,
                             EventKeys.eventUid : eventUUID,
                             EventKeys.timestamp : timestamp,
                             EventKeys.eventType : eventType,
                             PayloadKeys.data : [EventKeys.campaignID : campaignID]]
            
            return [eventJSON]
        }
    }
    
    return nil
}

func sendPNReceivedEventToServer(payload: JSONDictionary, apiKey: String) {
    if let eventJSON = pushNotifEventReceiveJSON(payload: payload) {
        do {
            if let url = URL(string: "https://api.tangotargeting.com/v4/events/") {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: eventJSON)
                request.setValue(apiKey, forHTTPHeaderField: "api-key")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                                    guard let data = data, error == nil else {
//                                        print("error=\(error)")
//                                        return
//                                    }
//                    
//                                    if let httpStatus = response as? HTTPURLResponse {
//                                        print("statusCode \(httpStatus.statusCode)")
//                                        print("response = \(response)")
//                                    }
//                    
//                                    let responseString = String(data: data, encoding: .utf8)
//                                    print("responseString = \(responseString)")
                }
                
                
                task.resume()
            }
        } catch {
            //  print("cannot create httpBody.")
        }
    }
}
