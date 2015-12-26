//
//  main.swift
//  BinaryJSON
//
//  Created by Alsey Coleman Miller on 12/26/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import XCTest

#if os(OSX) || os(iOS)
    func XCTMain(cases: [XCTestCase]) { fatalError("Not Implemented. Linux only") }
#endif

#if os(Linux)
    import Glibc
    XCTMain([BSONTests()])
#endif
