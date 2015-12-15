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
        public static let defualt = Context(internalPointer: bson_context_get_default())
        
        // MARK: - Properties
        
        // MARK: - Initialization
        
        deinit { bson_context_destroy(internalPointer) }
        
        public init(flags: Int) {
            
            
        }
        
        // MARK: - Internal
        
        internal let internalPointer: COpaquePointer
        
        internal init(internalPointer: COpaquePointer) {
            
            self.internalPointer = internalPointer
        }
    }
}