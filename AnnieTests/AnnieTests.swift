//
//  AnnieTests.swift
//  AnnieTests
//
//  Created by skyline on 15/1/6.
//  Copyright (c) 2015年 skyline. All rights reserved.
//

import Cocoa
import XCTest
//import Annie

class AnnieTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFromFile() {
        var input:NSString?
        var output: NSString?
        if let url1 = NSBundle(forClass: self.dynamicType).URLForResource("headers", withExtension: "text") {
            input = try? NSString(contentsOfURL: url1, encoding: NSUTF8StringEncoding)
        }
        if let url2 = NSBundle(forClass: self.dynamicType).URLForResource("headers", withExtension: "html") {
            output = try? NSString(contentsOfURL: url2, encoding: NSUTF8StringEncoding)
        }
        XCTAssertEqual(trimWhitespace(String(output!)), trimWhitespace(markdown(String(input!))))
    }
}
