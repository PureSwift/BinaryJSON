//
//  JSONEncodable.swift
//  BSON
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import CBSON

// MARK: - JSON String

public extension BSON {
    
    /// Converts the BSON document to JSON.
    static func toJSONString(document: BSON.Document) -> String {
        
       guard let pointer = unsafePointerFromDocument(document)
            else { fatalError("Could not convert document to unsafe pointer") }
        
        defer { bson_destroy(pointer) }
        
        return toJSONString(pointer)
    }
    
    /// Converts the BSON pointer to JSON.
    static func toJSONString(unsafePointer: UnsafePointer<bson_t>) -> String {
        
        var length = 0
        
        let stringBuffer = bson_as_json(unsafePointer, &length)
        
        defer { bson_free(stringBuffer) }
        
        let string = String.fromCString(stringBuffer)!
        
        return string
    }
}

// MARK: - JSONEncodable

extension BSON.Value: JSONEncodable {
    
    public func toJSON() -> JSON.Value {
        
        switch self {
            
        case .Null: return .Null
            
        case let .Number(number): return number.toJSON()
            
        case let .String(value): return .String(value)
            
        case let .Array(array): return array.toJSON()
            
        case let .Document(document): return document.toJSON()
            
        case let .Key(key): return key.toJSON()
            
        case let .Timestamp(timestamp): return timestamp.toJSON()
            
        case let .Binary(binary): return binary.toJSON()
            
        case let .Code(code): return code.toJSON()
            
        case let .ObjectID(objectID): return objectID.toJSON()
            
        case let .RegularExpression(regularExpression): return regularExpression.toJSON()
            
        case let .Date(date): return .Object(["$date": .Number(.Integer(Int(date.timeIntervalSince1970 * 1000)))])
        }
    }
}

extension BSON.Number: JSONEncodable {
    
    public func toJSON() -> JSON.Value {
        
        switch self {
            
        case let .Boolean(value): return .Number(.Boolean(value))
        case let .Double(value): return .Number(.Double(value))
        case let .Integer32(value): return .Number(.Integer(Int(value)))
        case let .Integer64(value): return .Number(.Integer(Int(value)))
        }
    }
}

extension BSON.Key: JSONEncodable {
    
    private enum JSONKey: String {
        
        case maxKey = "$maxKey"
        case minKey = "$minKey"
    }
    
    public func toJSON() -> JSON.Value {
        
        switch self {
        case .Maximum: return .Object([JSONKey.maxKey.rawValue: .Number(.Integer(1))])
        case .Minimum: return .Object([JSONKey.minKey.rawValue: .Number(.Integer(1))])
        }
    }
}

extension BSON.Timestamp: JSONEncodable {
    
    private enum JSONKey: String {
        
        case t, i, timestamp = "$timestamp"
    }
    
    public func toJSON() -> JSON.Value {
        
        return .Object([JSONKey.timestamp.rawValue: .Object([JSONKey.t.rawValue: .Number(.Integer(Int(time))), JSONKey.i.rawValue: .Number(.Integer(Int(oridinal)))])])
    }
}

extension BSON.Binary: JSONEncodable {
    
    private enum JSONKey: String {
        
        case binary = "$binary"
        case type = "$type"
    }
    
    public func toJSON() -> JSON.Value {
        
        let base64EncodedData = Base64.encode(self.data)
        
        guard let base64String = String(UTF8Data: base64EncodedData)
            else { fatalError("Could not create string from Base64 data") }
        
        let subtypeHexString = String(format:"%02hhX", subtype.rawValue)
        
        return .Object([JSONKey.binary.rawValue: .String(base64String), JSONKey.type.rawValue: .String(subtypeHexString)])
    }
}

extension BSON.Code: JSONEncodable {
    
    public func toJSON() -> JSON.Value {
        
        /*
        if let scope = self.scope {
            
            // appearently not exported to JSON
        }*/
        
        // no scope
        return .String(code)
    }
}

extension BSONObjectID: JSONEncodable {
    
    private static var JSONKey: String { return "$oid" }
    
    public func toJSON() -> JSON.Value {
        
        return .Object([BSON.ObjectID.JSONKey: .String(self.rawValue)])
    }
}

extension BSON.RegularExpression: JSONEncodable {
    
    private enum JSONKey: String {
        
        case regex = "$regex"
        case options = "$options"
    }
    
    public func toJSON() -> JSON.Value {
        
        return .Object([JSONKey.regex.rawValue: .String(pattern), JSONKey.options.rawValue: .String(options), ])
    }
}
