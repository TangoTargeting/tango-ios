//
//  PrintObjectDescription.swift
//  Tango
//
//  Created by Raul Hahn on 14/11/16.
//  Copyright © 2016 Tangotargetting. All rights reserved.
//

import Foundation

/// This protocol allows any class to be printed as if it were a struct.
/// To use it, your class must simply conform to PrintObjectDescription.
/// You don’t need to implement anything, the extension takes care of that.
///
/// If a class conform to this protocol, is no longer needed to override description property.
public protocol PrintObjectDescription : CustomStringConvertible , CustomDebugStringConvertible {}

extension PrintObjectDescription {
    
    public var description: String {
        return showObjectDescription(reflecting: self)
    }
    
    public var debugDescription: String {
        return showObjectDescription(reflecting: self)
    }
}

/// For classes that are inherited from NSObject we need to conform to NSObjectDescription protocol and use descriptionNSObject.
/// we cannot override description func in a NSObject extension in swift. So we need to create another property for this.
/// Since this protocol is used only for debuging we can use descriptionNSObject instead of description in this case.
public protocol NSObjectDescription: NSObjectProtocol {}

extension NSObjectDescription {
    public var descriptionNSObject: String {
        return showObjectDescription(reflecting: self)
    }
}

extension Mirror {
    /// The children of the mirror and its superclasses.
    var allChildren: [Mirror.Child] {
        var children = Array(self.children)
        var superclassMirror = self.superclassMirror
        
        while let mirror = superclassMirror {
            children.append(contentsOf: mirror.children)
            superclassMirror = mirror.superclassMirror
        }
        
        return children
    }
}

private func showObjectDescription(reflecting: Any) -> String {
    let mirror = Mirror(reflecting: reflecting)
    
    let descriptions: [String] = mirror.allChildren.flatMap { (label: String?, value: Any) in
        if let label = label {
            var value = value
            if value is String {
                value = "\"\(value)\""
            }
            return "\(label): \(value)"
        }
        
        return nil
    }
    
    return "\(mirror.subjectType)(\(descriptions.joined(separator: ", ")))"
}
