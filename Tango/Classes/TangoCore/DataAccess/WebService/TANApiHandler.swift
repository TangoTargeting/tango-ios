//
//  TANSyncComander.swift
//  Tango
//
//  Created by Raul Hahn on 10/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import Alamofire

#if DEBUG
//    private let kTangoBaseUrl = "http://192.168.1.73:3000/v4"
    private let kTangoBaseUrl = "https://api.tangotargeting.com/v4"
#else
    private let kTangoBaseUrl = "https://api.tangotargeting.com/v4"
#endif

typealias APICompletionHandler = (JSONDictionary?, Error?) -> Void

class TANApiHandler: PrintObjectDescription {
    
    // MARK: Tango requests
    
    func initialSync() {
        registerDevice {[weak self] (error) in
            if error != nil {
                dLogError(message: error!.localizedDescription)
            } else {
                self?.syncCampaigns(completionHandler: nil)
            }
        }
    }
    
    func registerDevice(completionHandler:((Error?) -> Void)?) {
        let requestURL: String = kTangoBaseUrl.appending("/devices")
        TANDeviceManager.sharedInstance.updateRegisterID(id: registeredID())
        if let params = TANDeviceManager.sharedInstance.currentDevice.toDictionary() as? JSONDictionary {
            request(url: requestURL, method: .post, parameters: params) { (responseDictionary, error) in
                if error != nil {
                    if completionHandler != nil {
                        completionHandler!(error)
                    }
                } else if let responseDict = responseDictionary {
                    if let dataDictionary = responseDict["data"] as? JSONDictionary {
                        TANPersistanceManager.sharedInstance.coreData.updateDeviceWithJSON(jsonDictionary: dataDictionary)
                    } else {
                        TANPersistanceManager.sharedInstance.coreData.updateDeviceWithJSON(jsonDictionary: responseDict)
                    }
                    if completionHandler != nil {
                        completionHandler!(nil)
                    }
                }
            };
        } else {
            dLogError(message: "There was an error on creating Device dictionary")
            if completionHandler != nil {
                completionHandler!(TangoError.deviceDictionaryNotCreated)
            }
        }
    }
    
    func syncCampaigns(completionHandler:((Error?)->Void)?) {
        request(url: campaignRequestUrl(), method: .get, parameters: [:]) { (responseDictionary, error) in
            if error != nil {
                if completionHandler != nil {
                    completionHandler!(error)
                }
            } else if let responseDict = responseDictionary {
                 TANPersistanceManager.sharedInstance.campaignDBManager.saveCampaignsFrom(dictionary: responseDict)
                if completionHandler != nil {
                    completionHandler!(nil)
                }
            }
        };
    }

    
    func addTags(tags: [TANTag], completionHandler:@escaping APICompletionHandler) {
        let requestURL: String = kTangoBaseUrl.appending("/devices/\(registeredID())/tags")
        return request(url: requestURL,
                       method: .post,
                       parameters: tagsDictionaryFromArray(tags: tags),
                       completionHandler: completionHandler)
    }
    
    func sendDeviceToken(token: String) {
        registerAppFromDevice(deviceToken: token, completionHandler: {_,_ in })
    }
    
    func registerAppFromDevice(deviceToken: String, completionHandler: @escaping APICompletionHandler) {
        let deviceID = registeredID()
        if  deviceID.isEmpty == false {
            let requestUrl = kTangoBaseUrl.appending("/devices/").appending(deviceID).appending("/tango_apps")
            if let params = appRequestBody(deviceToken: deviceToken) as JSONDictionary? {
                dLogDebug(message:"Put Device token with url: \(requestUrl), body:\(params) \n")
                TANAlamofireService().sessionManager.request(requestUrl, method: .put, parameters: params, encoding: JSONEncoding.default).validate().responseJSON {[weak self] response in
                    dLogDebug(message: "- Request is succesful: \(response.result.isSuccess)")
                    TANTangoService.sharedInstance.isAppRegistered = response.result.isSuccess
                    if let error = response.result.error {
                        error.printErrorDescription()
                        self?.printResponseData(responseData: response.data)
                        completionHandler(nil,error)
                    } else {
                        if let responseDictionary = response.result.value  as? JSONDictionary {
                            completionHandler(responseDictionary, nil)
                        } else {
                            completionHandler(nil, nil)
                        }
                    }
                }
            } else {
                completionHandler(nil, TangoError.appDictionaryNotCreated)
            }
        } else {
            completionHandler(nil, TangoError.deviceUIDNotValid)
        }
    }
    
    func syncEvents() {
        if let allEvents = TANPersistanceManager.sharedInstance.coreData.fetchRecordsFor(entityName: String(describing: CampaignEvent.self)) as? [CampaignEvent] {
            if allEvents.count > 0 {
                let requestUrl =  kTangoBaseUrl.appending("/events/")
                if let url = URL(string: requestUrl) {
                    do {
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.httpBody = try JSONSerialization.data(withJSONObject: eventsBody(campaignEvents: allEvents))
                        let serializedEventsUUID: [String] = eventsBody(campaignEvents: allEvents).map { $0["event_uid"] as? String ?? "" }
                        TANAlamofireService().sessionManager.request(request).validate().responseJSON(completionHandler: { [weak self] response in
                            if let statusCode = response.response?.statusCode {
                                if response.error != nil && !(200 ... 299 ~= statusCode) {
                                    response.result.error?.printErrorDescription()
                                    self?.printResponseData(responseData: response.data)
                                } else {
                                    TANPersistanceManager.sharedInstance.campaignDBManager.deleteEvents(eventsUUID: serializedEventsUUID)
                                }
                            }
                        })
                    } catch {
                        dLogError(message: "Error on serializing events")
                    }
                }
            } else {
                dLogDebug(message: "There are no events saved.")
            }
        }
    }
    
    func syncData() {
        // For now sync data is same as initial Sync. It will be chaged in the future.
        initialSync()
        syncEvents()
    }
    
    // MARK: Private methos
    
    private func eventsBody(campaignEvents: [CampaignEvent]) -> [JSONDictionary] {
        var events: [JSONDictionary] = []
        for (_, event) in campaignEvents.enumerated() {
            if let jsonEvent = encodedEvent(event: event) {
                events.append(jsonEvent)
            }
        }
        
        return events
    }
    
    private func campaignRequestUrl() -> String {
        let deviceID = registeredID()
        if  deviceID.isEmpty == false  {
            if TANLocationManager.sharedInstance.isLocationServiceEnable() {
                
                // we should add additional parameters if location service is enabled.
                if let latitude = TANLocationManager.sharedInstance.lastKnowLocationCoordinate?.latitude, let longitude = TANLocationManager.sharedInstance.lastKnowLocationCoordinate?.longitude {
                    let latitudeString = String(latitude)
                    let longitudeString = String(longitude)
                    
                    return kTangoBaseUrl.appending("/campaigns?device_uid=\(deviceID)&long=\(longitudeString)&lat=\(latitudeString)")
                }
                                        }
            return kTangoBaseUrl.appending("/campaigns?device_uid=\(deviceID)")
        }

        return kTangoBaseUrl.appending("/campaigns")
    }
    
    private func appRequestBody(deviceToken: String) -> [String: Any]? {
        if let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String,
            let bundleIdentifier = Bundle.main.infoDictionary![kCFBundleIdentifierKey as String] as? String {
            var requestDictionary: [String: String] = ["name":appName,
                                     "identifier":bundleIdentifier,
                                     "device_token": deviceToken,
                                     "os":"ios"]
            if let appIcon = getAppIcon() {
                if let imageData = UIImagePNGRepresentation(appIcon) {
                    requestDictionary["icon"] = imageData.base64EncodedString()
                }
            }
            
            return requestDictionary
        }
        
        return nil
    }
    
    private func printResponseData(responseData: Data?) {
        if let data = responseData, let utf8Text = String(data: data, encoding: .utf8) {
            dLogInfo(message: "Data: \(utf8Text)")
        }
    }
    
    private func request(url: String, method: HTTPMethod, parameters: JSONDictionary, completionHandler:@escaping APICompletionHandler) {
        TANAlamofireService().sessionManager.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON {[weak self] response in
            self?.handleRequestResponse(response: response, completionHandler: completionHandler)
        }
    }
    
    private func handleRequestResponse(response: DataResponse<Any>, completionHandler:@escaping APICompletionHandler) {
        dLogDebug(message: "- Request is succesful: \(response.result.isSuccess)")
        
        debugPrint("************* printing REQUEST parameter and Headers *************")
        debugPrint("RESPONSE : \(response.debugDescription)")
        
        if let error = response.result.error {
            error.printErrorDescription()
            self.printResponseData(responseData: response.data)
            completionHandler(nil,error)
        } else {
            if let responseDictionary = response.result.value  as? JSONDictionary {
                //if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    // dLog(message: "Data: \(utf8Text)")
              //  }
                completionHandler(responseDictionary, nil)
            } else {
                completionHandler(nil, nil)
            }
        }
    }
}
