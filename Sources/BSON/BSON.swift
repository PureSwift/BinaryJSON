//
//  BSON.swift
//  BSON
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(OSX)
    import bson
#elseif os(Linux)
    import CBSON
#endif

import SwiftFoundation

/// [Binary JSON](http://bsonspec.org)
///
///
public struct BSON {
    
    public typealias Array = [BSON.Value]
    
    public typealias Document = [String: BSON.Value]
    
    public enum Value {
        
        case Null
        
        case Array(BSON.Array)
        
        case Document(BSON.Document)
        
        case Number(BSON.Number)
        
        case Date(Int32)
        
        case Data([UInt8])
    }
    
    public enum Number {
        
        case Boolean(Bool)
        
        case Integer32(Int32)
        
        case Integer64(Int64)
        
        case Double(DoubleValue)
    }
}