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
    
    public struct ObjectID: ByteValue {
        
        public typealias ByteValueType = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
        
        public let byteValue: ByteValueType
    }
}

// MARK: - RawRepresentable

extension BSON.ObjectID: RawRepresentable {
    
    public init?(rawValue: String) {
        
        // must be 24 characters
        guard rawValue.utf8.count == 24
            else { return nil }
        
        let pointer = UnsafeMutablePointer<bson_oid_t>()
        defer { pointer.dealloc(1) }
        
        bson_oid_init_from_string_unsafe(pointer, rawValue)
        
        self.byteValue = pointer.memory.bytes
    }
    
    public var rawValue: String {
        
        let oidPointer = UnsafeMutablePointer<bson_oid_t>.alloc(1)
        defer { oidPointer.dealloc(1) }
        
        oidPointer.memory.bytes = self.byteValue
        
        let stringPointer = UnsafeMutablePointer<CChar>.alloc(25)
        defer { stringPointer.dealloc(25) }
        
        bson_oid_to_string(oidPointer, stringPointer)
        
        return String.fromCString(stringPointer)!
    }
}

// MARK: - Equatable

public func ==(lhs: BSON.ObjectID, rhs: BSON.ObjectID) -> Bool {
    
    var oid1 = bson_oid_t(bytes: lhs.byteValue)
    
    var oid2 = bson_oid_t(bytes: rhs.byteValue)
    
    return bson_oid_equal_unsafe(&oid1, &oid2)
}

// MARK: - Hashable

extension BSON.ObjectID: Hashable {
    
    public var hashValue: Int {
        
        let oidPointer = UnsafeMutablePointer<bson_oid_t>.alloc(1)
        defer { oidPointer.dealloc(1) }
        
        oidPointer.memory.bytes = self.byteValue
        
        let hash = bson_oid_hash_unsafe(oidPointer)
        
        return Int(hash)
    }
}






