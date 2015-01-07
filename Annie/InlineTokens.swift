//
//  InlineTokens.swift
//  swift-playground
//
//  Created by skyline on 15/1/6.
//  Copyright (c) 2015年 skyline. All rights reserved.
//

import Foundation

class InlineCode:TokenBase {
    var lang = String()
    init (text:String, lang:String) {
        super.init(type: "code", text: text)
        self.lang = lang
    }
    override func render() -> String {
        return "<code>\(text)</code>"
    }
}
