//
//  TANTag.swift
//  Tango
//
//  Created by Raul Hahn on 10/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

struct TANTag {
    var tagName: String = ""
}

func tagsDictionaryFromArray(tags: [TANTag]) -> JSONDictionary {
    var tagsArrayForBody: [String] = []
    for (_, value) in tags.enumerated() {
        tagsArrayForBody.append(value.tagName)
    }
    
    return [DeviceKeys().tags: tagsArrayForBody as AnyObject]
}

extension TANTag: Equatable {
    static func ==(lhs: TANTag, rhs: TANTag) -> Bool {
        return lhs.tagName == rhs.tagName
    }
}

extension TANTag: TANJSONEncodable {
    var jsonProperties:Array<String> {
        get {
            let deviceKeys = DeviceKeys()

            return [deviceKeys.tags]
        }
    }
    
    func valueForKey(key: String!) -> AnyObject! {
        let deviceKeys = DeviceKeys()
        
        if key == deviceKeys.tags {
            return self.tagName as AnyObject
        }
        
        return nil
    }
}
