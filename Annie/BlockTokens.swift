//
//  Tokens.swift
//  swift-playground
//
//  Created by skyline on 15/1/5.
//  Copyright (c) 2015年 skyline. All rights reserved.
//

import Foundation

class TokenBase {
    var type:String = ""
    var text:String = ""
    init (type:String, text:String) {
        self.type = type
        self.text = text
    }
    func render() -> String {
        return text
    }
}

class TokenNone: TokenBase {
    init() {
        super.init(type:"", text:"")
    }
    override func render() -> String {
        return ""
    }
}

class TokenEscapedText: TokenBase {
    override init (type:String, text:String) {
        super.init(type: type, text: escape(text))
    }
    override func render() -> String {
        return text
    }
}

class NewLine: TokenBase {
    init() {
        super.init(type: "newline", text: "")
    }
    
    override func render() -> String {
        return ""
    }
}

class Heading: TokenBase {
    var level:Int = 1
    init (text:String, level:Int) {
        super.init(type: "heading", text: text)
        self.level = level
    }
    override func render() -> String {
        return "<h\(level)>\(text)</h\(level)>"
    }
}

class BlockCode: TokenEscapedText {
    var lang = String()
    init (text:String, lang:String) {
        super.init(type: "code", text: text)
        self.lang = lang
    }
    override func render() -> String {
        if countElements(lang) == 0 {
            return "<pre><code>\(text)\n</code></pre>\n"
        }
        return "<pre><code class=\"lang-\(lang)\">\(text)\n</code></pre>\n"
    }
}

class HRule: TokenBase {
    init() {
        super.init(type: "hrule", text: "")
    }
    override func render() -> String {
        return "<hr>\n"
    }
}

class BlockQuote: TokenBase {
    override init(type:String, text:String) {
        super.init(type: type, text: text)
    }
    override func render() -> String {
        if type == "blockQuoteStart" {
            return "<blockquote>"
        } else {
            return "\n</blockquote>\n"
        }
    }
}

class ListBlock: TokenBase {
    var ordered: Bool = false
    init(type: String, ordered: Bool) {
        super.init(type: type, text: "")
        self.ordered = ordered
    }
    override func render() -> String {
        let tag = self.ordered ? "ol" : "ul"
        if type == "listBlockStart" {
            return "<\(tag)>"
        } else {
            return "</\(tag)>\n"
        }
    }
}

class ListItem: TokenBase {
    init(type: String) {
        super.init(type: type, text: "")
    }
    override func render() -> String {
        if type == "listItemStart" {
            return "<li>"
        } else {
            return "</li>"
        }
    }
}

