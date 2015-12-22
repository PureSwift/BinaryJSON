//
//  Extensions.swift
//  BinaryJSON
//
//  Created by Alsey Coleman Miller on 12/15/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation

// MARK: - Protocol

/// Type can be converted to BSON.
public protocol BSONEncodable {
    
    /// Encodes the reciever into BSON.
    func toBSON() -> BSON.Value
}

/// Type can be converted from BSON.
public protocol BSONDecodable {
    
    /// Decodes the reciever from BSON.
    init?(BSONValue: BSON.Value)
}

// MARK: - SwiftFoundation Types

// MARK: Null

extension SwiftFoundation.Null: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Null }
}

extension SwiftFoundation.Null: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Null else { return nil }
        
        self = value
    }
}

// MARK: Date

extension SwiftFoundation.Date: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Date(self) }
}

extension SwiftFoundation.Date: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Date else { return nil }
        
        self = value
    }
}

// MARK: Data

extension SwiftFoundation.Data: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Binary(BSON.Binary(data: self)) }
}

extension SwiftFoundation.Data: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        // generic binary is convertible to data
        guard let value = BSONValue.rawValue as? BSON.Binary where value.subtype == .Generic
            else { return nil }
        
        self = value.data
    }
}

// MARK: - Swift Standard Library Types

// MARK: Encodable

extension String: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .String(self) }
}

extension String: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? String else { return nil }
        
        self = value
    }
}

extension Int32: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Number(.Integer32(self)) }
}

extension Int32: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Int32 else { return nil }
        
        self = value
    }
}

extension Int64: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Number(.Integer64(self)) }
}

extension Int64: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Int64 else { return nil }
        
        self = value
    }
}

extension Double: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Number(.Double(self)) }
}

extension Double: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Double else { return nil }
        
        self = value
    }
}

extension Bool: BSONEncodable {
    
    public func toBSON() -> BSON.Value { return .Number(.Boolean(self)) }
}

extension Bool: BSONDecodable {
    
    public init?(BSONValue: BSON.Value) {
        
        guard let value = BSONValue.rawValue as? Bool else { return nil }
        
        self = value
    }
}

// MARK: - Collection Extensions

// MARK: Encodable

public extension CollectionType where Generator.Element: BSONEncodable {
    
    func toBSON() -> BSON.Value {
        
        var BSONArray = BSON.Array()
        
        for BSONEncodable in self {
            
            let BSONValue = BSONEncodable.toBSON()
            
            BSONArray.append(BSONValue)
        }
        
        return .Array(BSONArray)
    }
}

public extension Dictionary where Value: BSONEncodable, Key: StringLiteralConvertible {
    
    /// Encodes the reciever into BSON.
    func toBSON() -> BSON.Value {
        
        var document = BSON.Document()
        
        for (key, value) in self {
            
            let BSONValue = value.toBSON()
            
            let keyString = String(key)
            
            document[keyString] = BSONValue
        }
        
        return .Document(document)
    }
}

// MARK: Decodable

public extension BSONDecodable {
    
    /// Decodes from an array of BSON values.
    static func fromBSON(BSONArray: BSON.Array) -> [Self]? {
        
        var BSONDecodables = [Self]()
        
        for BSONValue in BSONArray {
            
            guard let BSONDecodable = self.init(BSONValue: BSONValue) else { return nil }
            
            BSONDecodables.append(BSONDecodable)
        }
        
        return BSONDecodables
    }
}

// MARK: - RawRepresentable Extensions

// MARK: Encode

public extension RawRepresentable where RawValue: BSONEncodable {
    
    /// Encodes the reciever into BSON.
    func toBSON() -> BSON.Value {
        
        return rawValue.toBSON()
    }
}

// MARK: Decode

public extension RawRepresentable where RawValue: BSONDecodable {
    
    /// Decodes the reciever from BSON.
    init?(BSONValue: BSON.Value) {
        
        guard let rawValue = RawValue(BSONValue: BSONValue) else { return nil }
        
        self.init(rawValue: rawValue)
    }
}

