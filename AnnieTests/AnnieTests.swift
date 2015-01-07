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
    
    func testEscape() {
        XCTAssertEqual("&amp;", markdown("&"), "&amp; escape Pass")
        XCTAssertEqual("&lt;", markdown("<"), "&lt; escape Pass")
        XCTAssertEqual("&gt;", markdown(">"), "&gt; escape Pass")
        XCTAssertEqual("&quot;", markdown("\""), "&quot; Pass")
        XCTAssertEqual("&#39;", markdown("\'"), "&#39; one Pass")
    }
    
    func testNewLine() {
        XCTAssertEqual("", markdown("\n"), "Newline one Pass")
        XCTAssertEqual("", markdown("\n\n"), "Newline two Pass")
    }
    
    func testHeading() {
        XCTAssertEqual("<h1>Hello</h1>", markdown("# Hello"), "H1 Heading Pass")
        XCTAssertEqual("<h2>Hello</h2>", markdown("## Hello"), "H2 Heading Pass")
        XCTAssertEqual("<h3>Hello</h3>", markdown("### Hello"), "H3 Heading Pass")
        XCTAssertEqual("<h4>Hello</h4>", markdown("#### Hello"), "H4 Heading Pass")
        XCTAssertEqual("<h5>Hello</h5>", markdown("##### Hello"), "H5 Heading Pass")
        XCTAssertEqual("<h6>Hello</h6>", markdown("###### Hello"), "H6 Heading Pass")
    }
    
    func testLHeading() {
        XCTAssertEqual("<h1>Hello</h1>", markdown("Hello\n====="), "H1 LHeading Pass")
        XCTAssertEqual("<h2>Hello</h2>", markdown("Hello\n-----"), "H2 LHeading Pass")
    }
    
    func testFencedCode() {
        XCTAssertEqual("<pre><code class=\"lang-swift\">println(&quot;Hello&quot;)\n</code></pre>\n", markdown("```swift\nprintln(\"Hello\")\n```"), "Fenced Code Pass")
    }
    
    func testBlockCode() {
        XCTAssertEqual("<pre><code>printf(&quot;Hello World&quot;)\n</code></pre>\n", markdown("    printf(\"Hello World\")"), "Block Code Pass")
    }
    
    func testHRule() {
        XCTAssertEqual("<hr>\n", markdown("-----"), "HRule dashes Pass")
        XCTAssertEqual("<hr>\n", markdown("***"), "HRule asterisks Pass")
        XCTAssertEqual("<hr>\n", markdown("___"), "HRule underscope Pass")
    }
    
    func testBlockQuote() {
        XCTAssertEqual("<blockquote><h3>Hello</h3>\n</blockquote>\n", markdown(">### Hello\n"), "HRule dashes Pass")
    }
    
    func testDefLinks() {
        XCTAssertEqual("<a href=\"www.google.com\">Google</a>", markdown("[Google][]\n\n [Google]:www.google.com\n"), "Deflink no title Pass")
        XCTAssertEqual("<a href=\"www.google.com\" title=\"GoogleSearch\">Google</a>", markdown("[Google][]\n\n [Google]:www.google.com \"GoogleSearch\"\n"), "Deflink no title Pass")
    }

    func testInlineCode() {
        XCTAssertEqual("<code>Hello</code>", markdown("`Hello`\n"), "InlineCode Pass")
    }
}
