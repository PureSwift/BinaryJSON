//
//  UnsafePointer.swift
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

public extension BSON {
    
    /// Creates an unsafe pointer of a BSON document for use with the C API.
    ///
    /// Make sure to use ```bson_destroy``` clean up the allocated BSON document.
    static func unsafePointerFromDocument(document: BSON.Document) -> UnsafePointer<bson_t>? {
        
        let documentPointer = bson_new()
        
        for (key, value) in document {
            
            let keyLength = Int32(key.utf8.count)
            
            switch value {
                
            case .Null:
                
                guard bson_append_null(documentPointer, key, keyLength) == true
                    else { return nil }
                
            case let .String(string):
                
                let stringLength = Int32(string.utf8.count)
                
                guard bson_append_utf8(documentPointer, key, keyLength, string, stringLength) == true
                    else { return nil }
                
            case let .Date(date):
                
                let secondsSince1970 = Int64(date.timeIntervalSince1970)
                
                guard bson_append_date_time(documentPointer, key, keyLength, secondsSince1970) == true
                    else { return nil }
                
            case let .Data(data):
                
                break
                
            case let .Document(document):
                
                guard bson_append_document(<#T##bson: UnsafeMutablePointer<bson_t>##UnsafeMutablePointer<bson_t>#>, <#T##key: UnsafePointer<Int8>##UnsafePointer<Int8>#>, <#T##key_length: Int32##Int32#>, <#T##value: UnsafePointer<bson_t>##UnsafePointer<bson_t>#>)
                
            case let .Array(array):
                
                bson_append_array(<#T##bson: UnsafeMutablePointer<bson_t>##UnsafeMutablePointer<bson_t>#>, <#T##key: UnsafePointer<Int8>##UnsafePointer<Int8>#>, <#T##key_length: Int32##Int32#>, <#T##array: UnsafePointer<bson_t>##UnsafePointer<bson_t>#>)
            }
        }
    }
    
    
}