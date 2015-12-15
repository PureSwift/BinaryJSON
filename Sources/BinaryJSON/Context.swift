//
//  Context.swift
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
    
    public final class Context {
        
        /// The default BSON context.
        public static let defualt = Context(internalPointer: bson_context_get_default(), options: [.ThreadSafe, .DisablePIDCache])
        
        // MARK: - Properties
        
        public let options: [Option]
        
        // MARK: - Initialization
        
        deinit { bson_context_destroy(internalPointer) }
        
        /// Initializes the context with the specified options.
        public init(options: [Option] = []) {
            
            let flags = options.optionsBitmask()
            
            self.options = options
            self.internalPointer = bson_context_new(bson_context_flags_t(rawValue: flags))
        }
        
        // MARK: - Internal
        
        internal let internalPointer: COpaquePointer
        
        internal init(internalPointer: COpaquePointer, options: [Option]) {
            
            self.options = options
            self.internalPointer = internalPointer
        }
    }
}

// MARK: - Supporting Types

public extension BSON.Context {
    
    public enum Option: UInt32, BitMaskOption {
        
        /// Context will be called from multiple threads.
        case ThreadSafe
        
        /// Call ```getpid()``` instead of caching the result of ```getpid()``` when initializing the context.
        case DisablePIDCache
        
        /// Call ```gethostname()``` instead of caching the result of ```gethostname()``` when initializing the context.
        case DisableHostCache
        
        public init?(rawValue: UInt32) {
            
            switch rawValue {
            case BSON_CONTEXT_THREAD_SAFE.rawValue: self = .ThreadSafe
            case BSON_CONTEXT_DISABLE_PID_CACHE.rawValue: self = .DisablePIDCache
            case BSON_CONTEXT_DISABLE_HOST_CACHE.rawValue: self = .DisableHostCache
            default: return nil
            }
        }
        
        public var rawValue: UInt32 {
            
            switch self {
            case .ThreadSafe: return BSON_CONTEXT_THREAD_SAFE.rawValue
            case .DisablePIDCache: return BSON_CONTEXT_DISABLE_PID_CACHE.rawValue
            case .DisableHostCache: return BSON_CONTEXT_DISABLE_HOST_CACHE.rawValue
            }
        }
    }
}



