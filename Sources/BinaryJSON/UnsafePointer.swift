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
    static func unsafePointerFromDocument(document: BSON.Document) -> UnsafeMutablePointer<bson_t>? {
        
        let documentPointer = bson_new()
        
        for (key, value) in document {
            
            guard appendValue(documentPointer, key: key, value: value) == true
                else { return nil }
        }
        
        return documentPointer
    }
    
    /// Creates a ```BSON.Document``` from an unsafe pointer. 
    ///
    /// - Precondition: The ```bson_t``` must be valid.
    static func documentFromUnsafePointer(documentPointer: UnsafeMutablePointer<bson_t>) -> BSON.Document? {
        
        var iterator = bson_iter_t()
        
        guard bson_iter_init(&iterator, documentPointer) == true
            else { return nil }
        
        var document = BSON.Document()
        
        while bson_iter_next(&iterator) {
            
            // key char buffer should not be changed or freed
            let keyBuffer = bson_iter_key_unsafe(&iterator)
            
            let key = String.fromCString(keyBuffer)
            
            let type = bson_iter_type_unsafe(&iterator)
            
            let value: BSON.Value
            
            switch type {
                
            case BSON_TYPE_DOUBLE:
                
                let doubleValue = bson_iter_double_unsafe(&iterator)
                
                value = .Number(.Double(doubleValue))
            }
        }
    }
}

private extension BSON {
    
    /// Appends a  ```BSON.Value``` to a document pointer. Returns false for if an error ocurred (over max limit).
    static func appendValue(documentPointer: UnsafeMutablePointer<bson_t>, key: String, value: BSON.Value) -> Bool {
        
        let keyLength = Int32(key.utf8.count)
        
        switch value {
            
        case .Null:
            
            return bson_append_null(documentPointer, key, keyLength)
            
        case let .String(string):
            
            let stringLength = Int32(string.utf8.count)
            
            return bson_append_utf8(documentPointer, key, keyLength, string, stringLength)
            
        case let .Number(number):
            
            switch number {
            case let .Boolean(value): return bson_append_bool(documentPointer, key, keyLength, value)
            case let .Integer32(value): return bson_append_int32(documentPointer, key, keyLength, value)
            case let .Integer64(value): return bson_append_int64(documentPointer, key, keyLength, value)
            case let .Double(value): return bson_append_double(documentPointer, key, keyLength, value)
            }
            
        case let .Date(date):
            
            let milisecondsSince1970 = Int64(date.timeIntervalSince1970 * 1000)
            
            return bson_append_date_time(documentPointer, key, keyLength, milisecondsSince1970)
            
        case let .Timestamp(timestamp):
            
            return bson_append_timestamp(documentPointer, key, keyLength, timestamp.time, timestamp.oridinal)
            
        case let .Binary(binary):
            
            let subtype: bson_subtype_t
            
            switch binary.subtype {
                
            case .Generic: subtype = BSON_SUBTYPE_BINARY
                
            case .Function: subtype = BSON_SUBTYPE_FUNCTION
                
            case .Old: subtype = BSON_SUBTYPE_BINARY_DEPRECATED
                
            case .UUIDOld: subtype = BSON_SUBTYPE_UUID_DEPRECATED
                
            case .UUID: subtype = BSON_SUBTYPE_UUID
                
            case .MD5: subtype = BSON_SUBTYPE_MD5
                
            case .User: subtype = BSON_SUBTYPE_USER
            }
            
            return bson_append_binary(documentPointer, key, keyLength, subtype, binary.data.byteValue, UInt32(binary.data.byteValue.count))
            
        case let .RegularExpression(regularExpression):
            
            return bson_append_regex(documentPointer, key, keyLength, regularExpression.pattern, regularExpression.options)
            
        case let .Key(keyType):
            
            switch keyType {
                
            case .Maximum:
                
                return bson_append_maxkey(documentPointer, key, keyLength)
                
            case .Minimum:
                
                return bson_append_minkey(documentPointer, key, keyLength)
            }
            
        case let .Code(code):
            
            if let scope = code.scope {
                
                guard let scopePointer = BSON.unsafePointerFromDocument(scope)
                    else { return false }
                
                return bson_append_code_with_scope(documentPointer, key, keyLength, code.code, scopePointer)
            }
            else {
                
                return bson_append_code(documentPointer, key, keyLength, code.code)
            }
            
        case let .ObjectID(objectID):
            
            var oid = bson_oid_t(bytes: objectID.byteValue)
            
            return bson_append_oid(documentPointer, key, keyLength, &oid)
            
        case let .Document(childDocument):
            
            let childDocumentPointer = UnsafeMutablePointer<bson_t>()
            
            guard bson_append_document_begin(documentPointer, key, keyLength, childDocumentPointer)
                else { return false }
        
            for (childKey, childValue) in childDocument {
                
                guard appendValue(childDocumentPointer, key: childKey, value: childValue)
                    else { return false }
            }
            
            return bson_append_document_end(documentPointer, childDocumentPointer)
            
        case let .Array(array):
            
            let childPointer = UnsafeMutablePointer<bson_t>()
            
            guard bson_append_array_begin(documentPointer, key, keyLength, childPointer)
                else { return false }
            
            for (index, subvalue) in array.enumerate() {
                
                let indexKey = "\(index)"
                
                guard appendValue(childPointer, key: indexKey, value: subvalue)
                    else { return false }
            }
            
            return bson_append_array_end(documentPointer, childPointer)
        }
    }
}




