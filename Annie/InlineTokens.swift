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

class LineBreak: TokenBase {
    init() {
        super.init(type: "linebreak", text: "")
    }
    override func render() -> String {
        return "<br>\n"
    }
}

class StrikeThrough: TokenBase {
    init(text:String) {
        super.init(type: "strikethrough", text: text)
    }
    override func render() -> String {
        return "<del>\(text)</del>"
    }
}

class AutoLink: TokenBase {
    var link = ""
    var title = ""
    var isEmail: Bool = false
    init(var link: String, isEmail: Bool = false) {
        super.init(type: "autolink", text: escape(link))
        self.link = self.text
        self.isEmail = isEmail
    }
    override func render() -> String {
        if isEmail {
            link = "mailto:\(link)"
        }
        return "<a href=\"\(link)\">\(text)</a>"
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

class Image: TokenBase {
    var src = ""
    var title = ""
    init(src: String, title: String, text: String) {
        super.init(type: "image", text: escape(text))
        self.src = src
        self.title = title
    }
    override func render() -> String {
        var html = ""
        if src.hasPrefix("javascript:") {
            src = ""
        }
        if !title.isEmpty {
            title = escape(title)
            html = "<img src=\"(src)\" alt=\"\(text)\" title=\"\(title)\""
        } else {
            html = "<img src=\"(src)\" alt=\"\(text)\""
        }
        return html + ">"
    }
}
