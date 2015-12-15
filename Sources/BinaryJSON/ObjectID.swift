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
    
    public struct ObjectID: ByteValue, RawRepresentable, Equatable, Hashable {
        
        // MARK: - Properties
        
        public typealias ByteValueType = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
        
        public var byteValue: ByteValueType {
            
            get { return internalClass.internalPointer.memory.bytes }
            
            mutating set {
            
                ensureUnique()
                internalClass.internalPointer.memory.bytes = newValue
            }
        }
        
        // MARK: - Initialization
        
        /// Default initializer. 
        ///
        /// Creates a new BSON ObjectID from the specified context, or the default context if none is specified.
        public init(context: Context? = nil) {
            
            let internalPointer = UnsafeMutablePointer<bson_oid_t>()
            
            bson_oid_init(internalPointer, context?.internalPointer ?? nil)
            
            self.internalClass = InternalClass(internalPointer: internalPointer)
        }
        
        // MARK: - Private
        
        private var internalClass: InternalClass
        
        private mutating func ensureUnique() {
            if !isUniquelyReferencedNonObjC(&internalClass) {
                internalClass = internalClass.copy()
            }
        }
    }
}

public extension BSON.ObjectID {
    
    // Date object ID was generated
    var date: Date {
        
        let time = bson_oid_get_time_t_unsafe(self.internalClass.internalPointer)
        
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
        
        let internalPointer = UnsafeMutablePointer<bson_oid_t>()
        
        bson_oid_init_from_string_unsafe(internalPointer, rawValue)
        
        self.internalClass = InternalClass(internalPointer: internalPointer)
    }
    
    public var rawValue: String {
        
        let stringPointer = UnsafeMutablePointer<CChar>.alloc(25)
        defer { stringPointer.dealloc(25) }
        
        bson_oid_to_string(internalClass.internalPointer, stringPointer)
        
        return String.fromCString(stringPointer)!
    }
}

// MARK: - Equatable

public func ==(lhs: BSON.ObjectID, rhs: BSON.ObjectID) -> Bool {
    
    // quicker with identity check if backed by same instance
    guard lhs.internalClass !== rhs.internalClass else { return true }
    
    // compare the values of the two pointers
    return bson_oid_equal_unsafe(lhs.internalClass.internalPointer, rhs.internalClass.internalPointer)
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
        
        let hash = bson_oid_hash_unsafe(internalClass.internalPointer)
        
        return Int(hash)
    }
}

// MARK: - Private

private extension BSON.ObjectID {
    
    /// Underlying storage for BSON Object ID.
    private final class InternalClass {
        
        private let internalPointer: UnsafeMutablePointer<bson_oid_t>
        
        /// Initialize the internal class with the BSON OID
        ///
        /// - Precondition: Pointer must be allocated and initialized
        private init(internalPointer: UnsafeMutablePointer<bson_oid_t>) {
            
            self.internalPointer = internalPointer
        }
        
        deinit {
            
            self.internalPointer.destroy()
            self.internalPointer.dealloc(1)
        }
        
        private func copy() -> InternalClass {
            
            let copy = UnsafeMutablePointer<bson_oid_t>()
            
            bson_oid_copy_unsafe(internalPointer, copy)
            
            return InternalClass(internalPointer: copy)
        }
    }
}



