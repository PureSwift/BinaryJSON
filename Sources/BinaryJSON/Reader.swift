//
//  Reader.swift
//  BinaryJSON
//
//  Created by Alsey Coleman Miller on 12/20/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import CBSON

public extension BSON {
    
    public final class Reader: GeneratorType {
        
        // MARK: - Private Properties
        
        private let internalPointer: UnsafeMutablePointer<bson_reader_t>
        
        // MARK: - Initialization
        
        public init(data: Data) {
            
            self.internalPointer = bson_reader_new_from_data(data.byteValue, data.byteValue.count)
        }
        
        deinit { bson_reader_destroy(internalPointer) }
        
        // MARK: - Methods
        
        public func next() -> BSON.Document? {
            
            var eof = false
            
            let valuePointer = bson_reader_read(internalPointer, &eof)
            
            guard valuePointer != nil else { return nil }
            
            // convert to document
            guard let document = BSON.documentFromUnsafePointer(UnsafeMutablePointer<bson_t>(valuePointer))
                else { return nil }
            
            return document
        }
    }
}