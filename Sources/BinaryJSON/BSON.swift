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
        
        case Data(DataValue)
        
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
    
    public enum Number {
        
        case Boolean(Bool)
        
        case Integer32(Int32)
        
        case Integer64(Int64)
        
        case Double(DoubleValue)
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
            
        case let .Data(data): return data
            
        case let .String(string): return string
        }
    }
    
    init?(rawValue: Any) {
        
        guard (rawValue as? SwiftFoundation.Null) == nil else {
            
            self = .Null
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
        
        if let data = rawValue as? SwiftFoundation.Data {
            
            self = .Data(data)
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

// MARK: - Typealiases

// Due to compiler error

public typealias DataValue = Data

public typealias DateValue = Date
