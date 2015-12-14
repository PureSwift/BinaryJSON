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
            
            guard appendValue(documentPointer, key: key, value: value) == true
                else { return nil }
        }
        
        return documentPointer
    }
}

private extension BSON {
    
    static func appendValue(documentPointer: UnsafeMutablePointer<bson_t>, key: String, value: BSON.Value) -> Bool {
        
        let keyLength = Int32(key.utf8.count)
        
        switch value {
            
        case .Null:
            
            return bson_append_null(documentPointer, key, keyLength)
            
        case let .String(string):
            
            let stringLength = Int32(string.utf8.count)
            
            return bson_append_utf8(documentPointer, key, keyLength, string, stringLength)
            
        case let .Date(date):
            
            let secondsSince1970 = Int64(date.timeIntervalSince1970)
            
            return bson_append_date_time(documentPointer, key, keyLength, secondsSince1970)
            
        case let .Data(data):
            
            break
            
        case let .Document(childDocument):
            
            let childDocumentPointer = UnsafeMutablePointer<bson_t>()
            
            bson_append_document_begin(documentPointer, key, keyLength, childDocumentPointer)
            
            for (childKey, childValue) in childDocument {
                
                appendValue(childDocumentPointer, key: key, value: childValue)
            }
            
            bson_append_document_end(documentPointer, childDocumentPointer)
            
        case let .Array(array):
            
            let childPointer = UnsafeMutablePointer<bson_t>()
            
            bson_append_array_begin(documentPointer, key, keyLength, childPointer)
            
            for (index, subvalue) in array.enumerate() {
                
                let indexKey = "\(index)"
                
                appendValue(childPointer, key: indexKey, value: subvalue)
            }
            
            bson_append_array_end(documentPointer, childPointer)
        }

    }
}




