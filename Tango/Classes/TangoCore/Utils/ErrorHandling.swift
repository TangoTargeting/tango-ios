//
//  ErrorHandling.swift
//  Tango
//
//  Created by Raul Hahn on 24/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation
import Alamofire

enum SerializationError: Error {
    case missing(String)
    case notSerialized(String)
}

enum TangoError: Error {
    case deviceDictionaryNotCreated
    case appDictionaryNotCreated
    case deviceUIDNotValid
}

extension Error {
    func printErrorDescription() {
        if let error = self as? AFError {
            switch error {
            case .invalidURL(let url):
                dLogError(message:"Invalid URL: \(url) - \(error.localizedDescription)")
                break
            case .parameterEncodingFailed(let reason):
                dLogError(message:"Parameter encoding failed: \(error.localizedDescription)")
                dLogError(message:"Failure Reason: \(reason)")
                break
            case .multipartEncodingFailed(let reason):
                dLogError(message:"Multipart encoding failed: \(error.localizedDescription)")
                dLogError(message:"Failure Reason: \(reason)")
                break
            case .responseValidationFailed(let reason):
                var errorString: String
                errorString = "Response validation failed: \(error.localizedDescription) \n Failure Reason: \(reason)."
                
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    errorString = errorString.appending("Downloaded file could not be read.")
                    break
                case .missingContentType(let acceptableContentTypes):
                    errorString = errorString.appending("Content Type Missing: \(acceptableContentTypes).")
                    break
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    errorString = errorString.appending("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes).")
                    break
                case .unacceptableStatusCode(let code):
                    errorString = errorString.appending("Response status code was unacceptable: \(code).")
                    break
                }
                dLogError(message: errorString)
                break
            case .responseSerializationFailed(let reason):
                dLogError(message:"Response serialization failed: \(error.localizedDescription)")
                dLogError(message:"Failure Reason: \(reason)")
                break
            }
            dLogError(message:"Underlying error: \(String(describing: error.underlyingError))")
        } else if let error = self as? URLError {
            dLogError(message:"URLError occurred: \(error)")
        } else {
            dLogError(message:"Unknown error: \(self)")
        }
    }
}
