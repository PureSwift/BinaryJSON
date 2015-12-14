//
//  ObjectID.swift
//  BinaryJSON
//
//  Created by Alsey Coleman Miller on 12/14/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(OSX)
    import bson
#elseif os(Linux)
    import CBSON
#endif

import SwiftFoundation

public extension BSON {
    
    public typealias ObjectID = bson_oid_t
}

// MARK: - ByteValue

extension BSON.ObjectID: ByteValue {
    
    public typealias ByteValueType = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    
    public var byteValue: ByteValueType {
        
        get { return bytes }
        
        set { self.bytes = newValue }
    }
}

// MARK: - RawRepresentable

extension BSON.ObjectID: RawRepresentable {
    
    public init?(rawValue: String) {
        
        // must be 24 characters
        guard rawValue.utf8.count == 24
            else { return nil }
        
        let pointer = UnsafeMutablePointer<bson_oid_t>()
        
        bson_oid_init_from_string_unsafe(pointer, rawValue)
        
        self = pointer.memory
    }
    
    public var rawValue: String {
        
        var copy = self
        
        let stringPointer = UnsafeMutablePointer<CChar>.alloc(25)
        defer { stringPointer.dealloc(25) }
        
        bson_oid_to_string(&copy, stringPointer)
        
        return String.fromCString(stringPointer)!
    }
}

// MARK: - Equatable

public func ==(lhs: BSON.ObjectID, rhs: BSON.ObjectID) -> Bool {
    
    var oid1 = lhs
    
    var oid2 = rhs
    
    return bson_oid_equal(&oid1, &oid2)
}



