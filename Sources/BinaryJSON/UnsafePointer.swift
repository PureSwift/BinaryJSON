//
//  UnsafePointer.swift
//  BSON
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import CBSON

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
        
        guard iterate(&document, iterator: &iterator) == true
            else { return nil }
        
        return document
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
            
            var time = timeval(timeInterval: date.timeIntervalSince1970)
            
            return bson_append_timeval(documentPointer, key, keyLength, &time)
            
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
            
            let childDocumentPointer = bson_new()
            
            defer { bson_destroy(childDocumentPointer) }
            
            guard bson_append_document_begin(documentPointer, key, keyLength, childDocumentPointer)
                else { return false }
        
            for (childKey, childValue) in childDocument {
                
                guard appendValue(childDocumentPointer, key: childKey, value: childValue)
                    else { return false }
            }
            
            return bson_append_document_end(documentPointer, childDocumentPointer)
            
        case let .Array(array):
            
            let childPointer = bson_new()
            
            defer { bson_destroy(childPointer) }
            
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
    
    /// iterate and append values to document
    static func iterate(inout document: BSON.Document, inout iterator: bson_iter_t) -> Bool {
        
        while bson_iter_next(&iterator) {
            
            // key char buffer should not be changed or freed
            let keyBuffer = bson_iter_key_unsafe(&iterator)
            
            guard let key = String.fromCString(keyBuffer)
                else { fatalError("Invalid key C string") }
            
            let type = bson_iter_type_unsafe(&iterator)
            
            var value: BSON.Value?
            
            switch type {
                
            case BSON_TYPE_DOUBLE:
                
                let double = bson_iter_double_unsafe(&iterator)
                
                value = .Number(.Double(double))
                
            case BSON_TYPE_UTF8:
                
                var length = 0
                
                let buffer = bson_iter_utf8_unsafe(&iterator, &length)
                
                guard let string = String.fromCString(buffer)
                    else { fatalError("Invalid C string") }
                
                value = .String(string)
                
            case BSON_TYPE_DOCUMENT:
                
                var childIterator = bson_iter_t()
                
                var childDocument = BSON.Document()
                
                guard bson_iter_recurse(&iterator, &childIterator) &&
                    iterate(&childDocument, iterator: &childIterator)
                    else { return false }
                
                value = .Document(childDocument)
                
            case BSON_TYPE_ARRAY:
                
                var childIterator = bson_iter_t()
                
                var childDocument = BSON.Document()
                
                guard bson_iter_recurse(&iterator, &childIterator) &&
                    iterate(&childDocument, iterator: &childIterator)
                    else { return false }
                
                let array = childDocument.map { (key, value) in return value }
                
                value = .Array(array)
                
            case BSON_TYPE_BINARY:
                
                var subtype = bson_subtype_t(rawValue: 0)
                
                var length: UInt32 = 0
                
                let bufferPointer = UnsafeMutablePointer<UnsafePointer<UInt8>>.alloc(1)
                
                defer { bufferPointer.dealloc(1) }
                
                bson_iter_binary(&iterator, &subtype, &length, bufferPointer)
                
                var bytes: [UInt8] = [UInt8](count: Int(length), repeatedValue: 0)
                
                memcpy(&bytes, bufferPointer.memory, Int(length))
                
                let data = Data(byteValue: bytes)
                
                let binarySubtype: Binary.Subtype
                
                switch subtype {
                    
                case BSON_SUBTYPE_BINARY: binarySubtype = .Generic
                case BSON_SUBTYPE_FUNCTION: binarySubtype = .Function
                case BSON_SUBTYPE_BINARY_DEPRECATED: binarySubtype = .Old
                case BSON_SUBTYPE_UUID_DEPRECATED: binarySubtype = .UUIDOld
                case BSON_SUBTYPE_UUID: binarySubtype = .UUID
                case BSON_SUBTYPE_MD5: binarySubtype = .MD5
                case BSON_SUBTYPE_USER: binarySubtype = .User
                    
                default: binarySubtype = .User
                }
                
                let binary = Binary(data: data, subtype: binarySubtype)
                
                value = .Binary(binary)
                
            // deprecated, no bindings
            case BSON_TYPE_DBPOINTER, BSON_TYPE_UNDEFINED, BSON_TYPE_SYMBOL: value = nil
                
            case BSON_TYPE_OID:
                
                /// should not be freed
                let oidPointer = bson_iter_oid_unsafe(&iterator)
                
                let objectID = ObjectID(byteValue: oidPointer.memory.bytes)
                
                value = .ObjectID(objectID)
                
            case BSON_TYPE_BOOL:
                
                let boolean = bson_iter_bool_unsafe(&iterator)
                
                value = .Number(.Boolean(boolean))
                
            case BSON_TYPE_DATE_TIME:
                
                var time = timeval()
                
                bson_iter_timeval(&iterator, &time)
                
                let date = Date(timeIntervalSince1970: time.timeIntervalValue)
                
                value = .Date(date)
                
            case BSON_TYPE_NULL:
                
                value = .Null
                
            case BSON_TYPE_REGEX:
                
                let optionsBufferPointer = UnsafeMutablePointer<UnsafePointer<CChar>>.alloc(1)
                
                defer { optionsBufferPointer.dealloc(1) }
                
                let patternBuffer = bson_iter_regex(&iterator, optionsBufferPointer)
                
                let optionsBuffer = optionsBufferPointer.memory
                
                let options = String.fromCString(optionsBuffer)!
                
                let pattern = String.fromCString(patternBuffer)!
                
                let regex = RegularExpression(pattern, options: options)
                
                value = .RegularExpression(regex)
                
            case BSON_TYPE_CODE:
                
                var length: UInt32 = 0
                
                let buffer = bson_iter_code_unsafe(&iterator, &length)
                
                let codeString = String.fromCString(buffer)!
                
                let code = Code(codeString)
                
                value = .Code(code)
                
            case BSON_TYPE_CODEWSCOPE:
                
                var codeLength: UInt32 = 0
                
                var scopeLength: UInt32 = 0
                
                let scopeBuffer = UnsafeMutablePointer<UnsafePointer<UInt8>>.alloc(1)
                
                defer { scopeBuffer.destroy(); scopeBuffer.dealloc(1) }
                
                let buffer = bson_iter_codewscope(&iterator, &codeLength, &scopeLength, scopeBuffer)
                
                let codeString = String.fromCString(buffer)!
                
                var scopeBSON = bson_t()
                
                guard bson_init_static(&scopeBSON, scopeBuffer.memory, Int(scopeLength))
                    else { return false }
                
                guard let scopeDocument = documentFromUnsafePointer(&scopeBSON)
                    else { fatalError("Could not ") }
                
                let code = Code(codeString, scope: scopeDocument)
                
                value = .Code(code)
                
            case BSON_TYPE_INT32:
                
                let integer = bson_iter_int32_unsafe(&iterator)
                
                value = .Number(.Integer32(integer))
                
            case BSON_TYPE_INT64:
                
                let integer = bson_iter_int64_unsafe(&iterator)
                
                value = .Number(.Integer64(integer))
                
            case BSON_TYPE_TIMESTAMP:
                
                var time: UInt32 = 0
                
                var increment: UInt32 = 0
                
                bson_iter_timestamp(&iterator, &time, &increment)
                
                let timestamp = Timestamp(time: time, oridinal: increment)
                
                value = .Timestamp(timestamp)
                
            case BSON_TYPE_MAXKEY:
                
                value = .Key(.Maximum)
                
            case BSON_TYPE_MINKEY:
                
                value = .Key(.Minimum)
                
            default: fatalError("Case \(type) not implemented")
            }
            
            // add key / value pair
            if let value = value {
                
                document[key] = value
            }
        }
        
        return true
    }
}




