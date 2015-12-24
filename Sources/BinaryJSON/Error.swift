//
//  Error.swift
//  BinaryJSON
//
//  Created by Alsey Coleman Miller on 12/20/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(OSX)
    import Darwin.C
#elseif os(Linux)
    import Glibc
#endif

import CBSON

public extension BSON {
    
    // BSON Error
    public struct Error: ErrorType {
        
        let domain: Domain
        
        let code: UInt32
        
        let message: String
        
        /// Initializes error with the values from the unsafe pointer. 
        ///
        /// - Precondition: The unsafe pointer is not ```nil```.
        public init(unsafePointer: UnsafePointer<bson_error_t>) {
            
            assert(unsafePointer != nil, "Trying to create Error from nil pointer")
            
            let domainCode = unsafePointer.memory.domain
            
            guard let domain = Domain(rawValue: domainCode)
                else { fatalError("Unknown Domain \(domainCode)") }
            
            var messageTuple = unsafePointer.memory.message
            
            let message = withUnsafePointer(&messageTuple) { (unsafeTuplePointer) -> String in
                
                let charPointer = unsafeBitCast(unsafeTuplePointer, UnsafePointer<CChar>.self)
                
                guard let string = String.fromCString(charPointer)
                    else { fatalError("Could not create string ") }
                
                return string
            }
            
            self.domain = domain
            self.message = message
            self.code = unsafePointer.memory.code
        }
    }
}

public extension BSON.Error {
    
    public enum Domain: UInt32 {
        
        case JSON = 1
        case Reader = 2
    }
}