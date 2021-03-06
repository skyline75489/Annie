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

class TokenInParagraph: TokenBase {
    override func render() -> String {
        return "<p>\(text)</p>"
    }
}

class TokenEscapedText: TokenBase {
    init (type:String, text:String, quote: Bool=false, smart_amp: Bool=true) {
        super.init(type: type, text: escape(text, quote: quote, smart_amp: smart_amp))
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

class Paragraph: TokenBase {
    init(text:String) {
        super.init(type: "paragraph", text: text)
    }
    override func render() -> String {
        return "<p>\(trimWhitespace(text))</p>\n"
    }
}

class Heading: TokenBase {
    var level:Int = 1
    init (text:String, level:Int) {
        super.init(type: "heading", text: text)
        self.level = level
    }
    override func render() -> String {
        return "<h\(level)>\(text)</h\(level)>\n"
    }
}

class BlockCode: TokenEscapedText {
    var lang = String()
    init (text:String, lang:String) {
        if lang.length == 0 {
            super.init(type: "code", text: text, smart_amp:false)
        } else {
            super.init(type: "code", text: text, quote: true, smart_amp:false)
        }
        self.lang = lang
    }
    override func render() -> String {
        if lang.length == 0 {
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

class LooseListItem:TokenBase {
    init(type: String) {
        super.init(type: type, text: "")
    }
    override func render() -> String {
        if type == "looseListItemStart" {
            return "<li><p>"
        } else {
            return "</p></li>"
        }
    }
}

