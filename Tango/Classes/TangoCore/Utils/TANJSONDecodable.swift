//
//  TANJSONDecodable.swift
//  Tango
//
//  Created by Raul Hahn on 16/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: AnyObject]

protocol TANJSONDecodable {
    init?(dictionary: JSONDictionary)
}

// flatMap to remove the nil results of mapping the dictionary to the JSONDecodable type.
func decode<T: TANJSONDecodable>(dictionaries: [JSONDictionary]) -> [T] {
    return dictionaries.flatMap{ T(dictionary: $0)}
}

func decode<T: TANJSONDecodable>(dictionary: JSONDictionary) -> T? {
    return T(dictionary: dictionary)
}

func decode<T:TANJSONDecodable>(data: NSData) -> [T]? {
    guard let JSONObject = try? JSONSerialization.jsonObject(with: data as Data, options: []),
        let dictionaries = JSONObject as? [JSONDictionary] else {
            return nil
    }
    
    return decode(dictionaries: dictionaries)
}

protocol TANJSONEncodable {
    var jsonProperties:Array<String> { get }
    func valueForKey(key: String!) -> AnyObject!
}

struct TANJSONEncode {
    static func toDictionary(obj:TANJSONEncodable) -> NSDictionary {
        // make dictionary
        var dict = Dictionary<String, AnyObject>()
        
        // add values
        for prop in obj.jsonProperties {
            let val:AnyObject? = obj.valueForKey(key: prop)
            
            if (val is String) {
                dict[prop] = val as AnyObject
            }
            else if (val is Int) {
                dict[prop] = val as AnyObject
            }
            else if (val is Float) {
                dict[prop] = val as AnyObject
            }
            else if (val is Double) {
                dict[prop] = val  as AnyObject
            }
            else if (val is Array<String>) {
                dict[prop] = val as AnyObject
            }
            else if (val is Array<TANTag>) {
                var arr = Array<String>()
                for item in (val as! Array<TANTag>) { // TODO: HR add a protocol for array of strings as a value and if conform to it do the trick.
                    arr.append(item.tagName)
                }
                dict[prop] = arr as AnyObject
            }
            else if (val is TANJSONEncodable) {
                dict[prop] = toDictionary(obj:val as! TANJSONEncodable)
            }
            else if (val is Array<TANJSONEncodable>) {
                var arr = Array<NSDictionary>()
                
                for item in (val as! Array<TANJSONEncodable>) {
                    arr.append(toDictionary(obj: item))
                }
                
                dict[prop] = arr as AnyObject
            }
            
        }
        
        // return dict
        return dict as NSDictionary
    }
    
    static func toJSON(obj:TANJSONEncodable) -> String? {
        // get dict
        let dict = toDictionary(obj: obj)
        
        // make JSON
        var data:Data?
        do {
            data = try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch {
            print(error)
        }
        
        // return result
        return String(data: data!, encoding: .utf8)
    }
}
