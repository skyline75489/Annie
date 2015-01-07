//
//  InlineTokens.swift
//  swift-playground
//
//  Created by skyline on 15/1/7.
//  Copyright (c) 2015年 skyline. All rights reserved.
//

import Foundation

class InlineCode: TokenBase {
    var lang = ""
    init (text:String) {
        super.init(type: "code", text: text)
    }
    override func render() -> String {
        return "<code>\(text)</code>"
    }
}

class Link: TokenBase {
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
            //TODO Escape
            self.fullText = "<a href=\"\(link)\" title=\"\(title)\">\(text)</a>"
        }
    }
    
    override func render() -> String {
        return self.fullText
    }
    
}
