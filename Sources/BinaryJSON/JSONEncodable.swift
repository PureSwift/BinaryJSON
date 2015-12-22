//
//  JSONEncodable.swift
//  BSON
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(OSX)
    import bson
#elseif os(Linux)
    import CBSON
#endif

import SwiftFoundation

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
            
        case let .Number(number): number.toJSON()
            
        case let .String(value): return .String(value)
            
        case let .Array(array): return array.toJSON()
            
        case let .Document(document): return document.toJSON()
            
        case let .Key(key): return key.toJSON()
            
        case let .Timestamp(timestamp): return timestamp.toJSON()
            
        case let .Binary(binary): return Binary.toJSON()
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
        
        case t, i
    }
    
    public func toJSON() -> JSON.Value {
        
        return .Object([JSONKey.t.rawValue: .Number(.Integer(Int(time))), JSONKey.i.rawValue: .Number(.Integer(Int(oridinal)))])
    }
}

extension BSON.Binary: BSONEncodable {
    
    
}

