//
//  TANAlamofireServiceswift
//  Tango
//
//  Created by Raul Hahn on 14/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import Alamofire

class TANAlamofireService {
    let sessionManager = SessionManager.default

    init() {
        sessionManager.adapter = AlamofireHeadersAdapter()
    }

}

class AlamofireHeadersAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        urlRequest.setValue(TANTangoService.sharedInstance.sdkApiKey, forHTTPHeaderField: "api-key")
        
        return urlRequest
    }
}
