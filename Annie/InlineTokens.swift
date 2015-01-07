//
//  InlineTokens.swift
//  swift-playground
//
//  Created by skyline on 15/1/7.
//  Copyright (c) 2015年 skyline. All rights reserved.
//

import Foundation

class InlineCode: TokenEscapedText {
    var lang = ""
    init (text:String) {
        super.init(type: "code", text: text)
    }
    override func render() -> String {
        return "<code>\(text)</code>"
    }
}

class Link: TokenEscapedText {
    var link = ""
    var title = ""
    var fullText = ""
    init(title:String, link:String, text:String) {
        super.init(type: "link", text: text)
        if link.hasPrefix("javascript") {
            self.link = ""
        }
        if title.isEmpty {
            self.fullText = "<a href=\"\(link)\">\(text)</a>"
        } else {
            self.fullText = "<a href=\"\(link)\" title=\"\(escape(title))\">\(text)</a>"
        }
    }
    
    override func render() -> String {
        return self.fullText
    }
}

class DoubleEmphasis: TokenEscapedText {
    init(text: String) {
        super.init(type: "double_emphasis", text: text)
    }
    
    override func render() -> String {
        return "<strong>\(text)</strong>"
    }
}

class Emphasis: TokenEscapedText {
    init(text: String) {
        super.init(type: "emphasis", text: text)
    }
    
    override func render() -> String {
        return "<em>\(text)</em>"
    }
}
