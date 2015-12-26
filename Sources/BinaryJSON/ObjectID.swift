//
//  ObjectID.swift
//  BinaryJSON
//
//  Created by Alsey Coleman Miller on 12/14/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import CBSON

public extension BSON {
    
    public typealias ObjectID = BSONObjectID
}

/// BSON Object Identifier.
public struct BSONObjectID: ByteValueType, RawRepresentable, Equatable, Hashable, CustomStringConvertible {
    
    // MARK: - Properties
    
    public typealias ByteValue = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    
    public var byteValue: ByteValue {
        
        get { return self.internalValue.bytes }
        
        set { self.internalValue.bytes = newValue }
    }
    
    // MARK: - Private Properties
    
    private var internalValue: bson_oid_t
    
    // MARK: - Initialization
    
    /// Default initializer.
    ///
    /// Creates a new BSON ObjectID from the specified context, or the default context if none is specified.
    public init(context: BSON.Context? = nil) {
        
        var objectID = bson_oid_t()
        
        bson_oid_init(&objectID, context?.internalPointer ?? nil)
        
        self.internalValue = objectID
    }
    
    public init(byteValue: ByteValue) {
        
        self.internalValue = bson_oid_t(bytes: byteValue)
    }
}

public extension BSON.ObjectID {
    
    /// Date object ID was generated
    var date: Date {
        
        var objectID = internalValue
        
        let time = bson_oid_get_time_t_unsafe(&objectID)
        
        return Date(timeIntervalSince1970: TimeInterval(time))
    }
}

// MARK: - RawRepresentable

public extension BSON.ObjectID {
    
    public init?(rawValue: String) {
        
        // must be 24 characters
        guard rawValue.utf8.count == 24 &&
            bson_oid_is_valid(rawValue, rawValue.utf8.count)
            else { return nil }
        
        var objectID = bson_oid_t()
        
        bson_oid_init_from_string_unsafe(&objectID, rawValue)
        
        self.internalValue = objectID
    }
    
    public var rawValue: String {
        
        let stringPointer = UnsafeMutablePointer<CChar>.alloc(25)
        defer { stringPointer.dealloc(25) }
        
        var objectID = internalValue
        
        bson_oid_to_string(&objectID, stringPointer)
        
        return String.fromCString(stringPointer)!
    }
}

// MARK: - CustomStringConvertible

public extension BSON.ObjectID {
    
    var description: String { return rawValue }
}

// MARK: - Equatable

public func ==(lhs: BSON.ObjectID, rhs: BSON.ObjectID) -> Bool {
    
    var oid1 = lhs.internalValue
    var oid2 = rhs.internalValue
    
    return bson_oid_equal_unsafe(&oid1, &oid2)
}

/*
// MARK: - Comparable

public func <(lhs: BSON.ObjectID, rhs: BSON.ObjectID) -> Bool {
    
    return bson_oid_compare_unsafe(lhs.internalClass.internalPointer, rhs.internalClass.internalPointer) < 0
}
*/

// MARK: - Hashable

public extension BSON.ObjectID {
    
    public var hashValue: Int {
        
        var objectID = internalValue
        
        let hash = bson_oid_hash_unsafe(&objectID)
        
        return Int(hash)
    }
}



