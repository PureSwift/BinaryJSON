//
//  BSON.swift
//  BSON
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation

/// [Binary JSON](http://bsonspec.org)
public struct BSON {
    
    /// BSON Array
    public typealias Array = [BSON.Value]
    
    /// BSON Document
    public typealias Document = [String: BSON.Value]
    
    /// BSON value type. 
    public enum Value: RawRepresentable, Equatable, CustomStringConvertible {
        
        case Null
        
        case Array(BSON.Array)
        
        case Document(BSON.Document)
        
        case Number(BSON.Number)
        
        case String(StringValue)
        
        case Date(DateValue)
        
        case Timestamp(BSON.Timestamp)
        
        case Binary(BSON.Binary)
        
        case Code(BSON.Code)
        
        case ObjectID(BSON.ObjectID)
        
        case RegularExpression(BSON.RegularExpression)
        
        case Key(BSON.Key)
        
        // MARK: - Extract Values
        
        /// Tries to extract an array value from a ```BSON.Value```.
        ///
        /// - Note: Does not convert the individual elements of the array to their raw values.
        public var arrayValue: BSON.Array? {
            
            switch self {
            case let .Array(value): return value
            default: return nil
            }
        }
        
        /// Tries to extract a document value from a ```BSON.Value```.
        ///
        /// - Note: Does not convert the values of the document to their raw values.
        public var documentValue: BSON.Document? {
            
            switch self {
            case let .Document(value): return value
            default: return nil
            }
        }
    }
    
    public enum Number: Equatable {
        
        case Boolean(Bool)
        
        case Integer32(Int32)
        
        case Integer64(Int64)
        
        case Double(DoubleValue)
    }
    
    public struct Binary: Equatable {
        
        public enum Subtype: Byte {
            
            case Generic    = 0x00
            case Function   = 0x01
            case Old        = 0x02
            case UUIDOld    = 0x03
            case UUID       = 0x04
            case MD5        = 0x05
            case User       = 0x80
        }
        
        public var data: Data
        
        public var subtype: Subtype
        
        public init(data: Data, subtype: Subtype = .Generic) {
            
            self.data = data
            self.subtype = subtype
        }
    }
    
    /// Represents a string of Javascript code.
    public struct Code: Equatable {
        
        public var code: String
        
        public var scope: BSON.Document?
        
        public init(_ code: String, scope: BSON.Document? = nil) {
            
            self.code = code
            self.scope = scope
        }
    }
    
    /// BSON maximum and minimum representable types.
    public enum Key {
        
        case Minimum
        case Maximum
    }
        
    public struct Timestamp: Equatable {
        
        /// Seconds since the Unix epoch.
        public var time: UInt32
        
        /// Prdinal for operations within a given second. 
        public var oridinal: UInt32
        
        public init(time: UInt32, oridinal: UInt32) {
            
            self.time = time
            self.oridinal = oridinal
        }
    }
    
    public struct RegularExpression: Equatable {
        
        public var pattern: String
        
        public var options: String
        
        public init(_ pattern: String, options: String) {
            
            self.pattern = pattern
            self.options = options
        }
    }
}

// MARK: - RawRepresentable

public extension BSON.Value {
    
    var rawValue: Any {
        
        switch self {
            
        case .Null: return SwiftFoundation.Null()
            
        case let .Array(array):
            
            let rawValues = array.map { (value) in return value.rawValue }
            
            return rawValues
            
        case let .Document(document):
            
            var rawObject = [StringValue: Any]()
            
            for (key, value) in document {
                
                rawObject[key] = value.rawValue
            }
            
            return rawObject
            
        case let .Number(number): return number.rawValue
            
        case let .Date(date): return date
            
        case let .Timestamp(timestamp): return timestamp
            
        case let .Binary(binary): return binary
            
        case let .String(string): return string
            
        case let .Key(key): return key
            
        case let .Code(code): return code
            
        case let .ObjectID(objectID): return objectID
            
        case let .RegularExpression(regularExpression): return regularExpression
        }
    }
    
    init?(rawValue: Any) {
        
        guard (rawValue as? SwiftFoundation.Null) == nil else {
            
            self = .Null
            return
        }
        
        if let key = rawValue as? BSON.Key {
            
            self = .Key(key)
            return
        }
        
        if let string = rawValue as? Swift.String {
            
            self = .String(string)
            return
        }
        
        if let date = rawValue as? SwiftFoundation.Date {
            
            self = .Date(date)
            return
        }
        
        if let timestamp = rawValue as? BSON.Timestamp {
            
            self = .Timestamp(timestamp)
            return
        }
        
        if let binary = rawValue as? BSON.Binary {
            
            self = .Binary(binary)
            return
        }
        
        if let number = BSON.Number(rawValue: rawValue) {
            
            self = .Number(number)
            return
        }
        
        if let rawArray = rawValue as? [Any], let jsonArray: [BSON.Value] = BSON.Value.fromRawValues(rawArray) {
            
            self = .Array(jsonArray)
            return
        }
        
        if let rawDictionary = rawValue as? [Swift.String: Any] {
            
            var document = BSON.Document()
            
            for (key, rawValue) in rawDictionary {
                
                guard let bsonValue = BSON.Value(rawValue: rawValue) else { return nil }
                
                document[key] = bsonValue
            }
            
            self = .Document(document)
            return
        }
        
        if let code = rawValue as? BSON.Code {
            
            self = .Code(code)
            return
        }
        
        if let objectID = rawValue as? BSON.ObjectID {
            
            self = .ObjectID(objectID)
            return
        }
        
        if let regularExpression = rawValue as? BSON.RegularExpression {
            
            self = .RegularExpression(regularExpression)
            return
        }
        
        return nil
    }
}

public extension BSON.Number {
    
    public var rawValue: Any {
        
        switch self {
        case .Boolean(let value): return value
        case .Integer32(let value): return value
        case .Integer64(let value): return value
        case .Double(let value):  return value
        }
    }
    
    public init?(rawValue: Any) {
        
        if let value = rawValue as? Bool            { self = .Boolean(value) }
        if let value = rawValue as? Int32           { self = .Integer32(value) }
        if let value = rawValue as? Int64           { self = .Integer64(value) }
        if let value = rawValue as? DoubleValue     { self = .Double(value)  }
        
        return nil
    }
}

// MARK: - CustomStringConvertible

public extension BSON.Value {
    
    public var description: Swift.String { return "\(rawValue)" }
}

public extension BSON.Number {
    
    public var description: Swift.String { return "\(rawValue)" }
}

// MARK: Equatable

public func ==(lhs: BSON.Value, rhs: BSON.Value) -> Bool {
    
    switch (lhs, rhs) {
        
    case (.Null, .Null): return true
        
    case let (.String(leftValue), .String(rightValue)): return leftValue == rightValue
        
    case let (.Number(leftValue), .Number(rightValue)): return leftValue == rightValue
        
    case let (.Array(leftValue), .Array(rightValue)): return leftValue == rightValue
        
    case let (.Document(leftValue), .Document(rightValue)): return leftValue == rightValue
        
    case let (.Date(leftValue), .Date(rightValue)): return leftValue == rightValue
        
    case let (.Timestamp(leftValue), .Timestamp(rightValue)): return leftValue == rightValue
        
    case let (.Binary(leftValue), .Binary(rightValue)): return leftValue == rightValue
        
    case let (.Code(leftValue), .Code(rightValue)): return leftValue == rightValue
        
    case let (.ObjectID(leftValue), .ObjectID(rightValue)): return leftValue == rightValue
        
    case let (.RegularExpression(leftValue), .RegularExpression(rightValue)): return leftValue == rightValue
        
    case let (.Key(leftValue), .Key(rightValue)): return leftValue == rightValue
        
    default: return false
    }
}

public func ==(lhs: BSON.Number, rhs: BSON.Number) -> Bool {
    
    switch (lhs, rhs) {
        
    case let (.Boolean(leftValue), .Boolean(rightValue)): return leftValue == rightValue
        
    case let (.Integer32(leftValue), .Integer32(rightValue)): return leftValue == rightValue
        
    case let (.Integer64(leftValue), .Integer64(rightValue)): return leftValue == rightValue
        
    case let (.Double(leftValue), .Double(rightValue)): return leftValue == rightValue
        
    default: return false
    }
}

public func ==(lhs: BSON.Timestamp, rhs: BSON.Timestamp) -> Bool {
    
    return lhs.time == rhs.time && lhs.oridinal == rhs.oridinal
}

public func ==(lhs: BSON.Binary, rhs: BSON.Binary) -> Bool {
    
    return lhs.data == rhs.data && lhs.subtype == rhs.subtype
}

public func ==(lhs: BSON.Code, rhs: BSON.Code) -> Bool {
    
    if let leftScope = lhs.scope {
        
        guard let rightScope = rhs.scope where rightScope == leftScope
            else { return false }
    }
    
    return lhs.code == rhs.code
}

public func ==(lhs: BSON.RegularExpression, rhs: BSON.RegularExpression) -> Bool {
    
    return lhs.pattern == rhs.pattern && lhs.options == rhs.options
}

// MARK: - Typealiases

// Due to compiler error

public typealias DataValue = Data

public typealias DateValue = Date

