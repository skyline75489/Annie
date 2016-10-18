//
//  Annie.swift
//  Annie
//
//  Created by skyline on 15/1/6.
//  Copyright (c) 2015年 skyline. All rights reserved.
//

import Foundation

func escape(_ text: String, quote: Bool=false, smart_amp: Bool=true) -> String {
    var text = text
    
    let escapeRegex = try! NSRegularExpression(pattern: "&(?!#?\\w+;)", options: NSRegularExpression.Options.caseInsensitive)
    
    if smart_amp {
        text = escapeRegex.stringByReplacingMatches(in: text, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, text.length), withTemplate: "&amp;")
    } else {
        text = text.replacingOccurrences(of: "&", with: "&amp;", options: NSString.CompareOptions.literal, range: nil)
    }
    
    text = text.replacingOccurrences(of: "<", with: "&lt;", options: NSString.CompareOptions.literal, range: nil)
    text = text.replacingOccurrences(of: ">", with: "&gt;", options: NSString.CompareOptions.literal, range: nil)
    if quote {
        text = text.replacingOccurrences(of: "\"", with: "&quot;", options: NSString.CompareOptions.literal, range: nil)
        text = text.replacingOccurrences(of: "'", with: "&#39;", options: NSString.CompareOptions.literal, range: nil)
    }
    return text
}

func preprocessing(_ text:String, tab: Int=4) -> String {
    var text = text
    let newlineRegex = try! NSRegularExpression(pattern: "\\r\\n|\\r", options: NSRegularExpression.Options.caseInsensitive)
    text = newlineRegex.stringByReplacingMatches(in: text, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, text.length), withTemplate: "\n")
    text = text.replacingOccurrences(of: "\t", with: " ".repeatString(tab))
    text = text.replacingOccurrences(of: "\u{00a0}", with: "")
    text = text.replacingOccurrences(of: "\u{2424}", with: "\n")
    
    let leadingSpaceRegex = try! NSRegularExpression(pattern: "^ +$", options: NSRegularExpression.Options.anchorsMatchLines)
    text = leadingSpaceRegex.stringByReplacingMatches(in: text, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, text.length), withTemplate: "")
    return text
}

func trimWhitespace(_ text: String) -> String {
    let regex = try! NSRegularExpression(pattern: "\\s", options: NSRegularExpression.Options.caseInsensitive)
    return regex.stringByReplacingMatches(in: text, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, text.length), withTemplate: "")
}

func getPurePattern(_ pattern:String) -> String {
    var p = pattern
    if pattern.hasPrefix("^") {
        p = pattern.substring(from: pattern.characters.index(pattern.startIndex, offsetBy: 1))
    }
    return p
}

func keyify(_ key: String) -> String {
    let keyWhiteSpaceRegex = try! NSRegularExpression(pattern: "\\s+", options: NSRegularExpression.Options.caseInsensitive)
    return keyWhiteSpaceRegex.stringByReplacingMatches(in: key.lowercased(), options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, key.length), withTemplate: " ")
}

class BlockParser {
    var definedLinks = [String:[String:String]]()
    var tokens = [TokenBase]()
    var grammarRegexMap = [String:Regex]()
    
    let defaultRules = ["newline", "hrule", "block_code", "fences", "heading",
        "nptable", "lheading", "block_quote",
        "list_block", "block_html", "def_links",
        "def_footnotes", "table", "paragraph", "text"]
    
    let listRules = ["newline", "block_code", "fences", "lheading", "hrule",
        "block_quote", "list_block", "block_html", "text",]
    
    init() {
        let def_links_regex = "^ *\\[([^^\\]]+)\\]: *<?([^\\s>]+)>?(?: +[\"(]([^\n]+)[\")])? *(?:\n+|$)"
        let def_footnotes_regex = "^\\[\\^([^\\]]+)\\]: *([^\n]*(?:\n+|$)(?: {1,}[^\n]*(?:\n+|$))*)"
        let newline_regex = "^\n+"
        let heading_regex = "^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)"
        let lheading_regex = "^([^\n]+)\n *(=|-)+ *(?:\n+|$)"
        let fences_regex = "^ *(`{3,}|~{3,}) *(\\S+)? *\n([\\s\\S]+?)\\s\\1 *(?:\\n+|$)"
        let block_code_regex = "^( {4}[^\n]+\n*)+"
        let hrule_regex = "^ {0,3}[-*_](?: *[-*_]){2,} *(?:\n+|$)"
        let block_quote_regex = "^( *>[^\n]+(\n[^\n]+)*\n*)+"
        
        let list_block_regex = String(format: "^( *)([*+-]|\\d+\\.) [\\s\\S]+?(?:\\n+(?=\\1?(?:[-*_] *){3,}(?:\\n+|$))|\\n+(?=%@)|\\n{2,}(?! )(?!\\1(?:[*+-]|\\d+\\.) )\\n*|\\s*$)", def_links_regex)
        
        let list_item_regex = "^(( *)(?:[*+-]|\\d+\\.) [^\\n]*(?:\\n(?!\\2(?:[*+-]|\\d+\\.) )[^\\n]*)*)"
        let list_bullet_regex = "^ *(?:[*+-]|\\d+\\.) +"
        
        let paragraph_regex = String(format: "^((?:[^\\n]+\\n?(?!%@|%@|%@|%@|%@|%@|%@))+)\\n*",  getPurePattern(fences_regex).replacingOccurrences(of: "\\1", with: "\\2"), getPurePattern(list_block_regex).replacingOccurrences(of: "\\1", with: "\\3"), getPurePattern(hrule_regex), getPurePattern(heading_regex), getPurePattern(lheading_regex), getPurePattern(block_quote_regex), getPurePattern(def_links_regex))
        
        let text_regex = "^[^\n]+"
        
        //let def_footnotes_regex = self.grammarRegexMap["def_footnotes"]!
        
        addGrammar("def_links", regex: Regex(pattern: def_links_regex))
        addGrammar("def_footnotes", regex: Regex(pattern:def_footnotes_regex))
        addGrammar("newline", regex: Regex(pattern: newline_regex))
        addGrammar("heading", regex: Regex(pattern: heading_regex))
        addGrammar("lheading", regex: Regex(pattern: lheading_regex))
        addGrammar("fences", regex: Regex(pattern: fences_regex))
        addGrammar("block_code", regex: Regex(pattern: block_code_regex))
        addGrammar("hrule", regex: Regex(pattern: hrule_regex))
        addGrammar("block_quote", regex: Regex(pattern: block_quote_regex))
        
        
        addGrammar("list_block", regex: Regex(pattern: list_block_regex))
        addGrammar("list_item", regex: Regex(pattern: list_item_regex, options: NSRegularExpression.Options.anchorsMatchLines))
        addGrammar("list_bullet", regex: Regex(pattern: list_bullet_regex))
        addGrammar("paragraph", regex: Regex(pattern: paragraph_regex))
        addGrammar("text", regex: Regex(pattern: text_regex))
    }
    
    func addGrammar(_ name:String, regex:Regex) {
        grammarRegexMap[name] = regex
    }
    
    func forward(_ text:inout String, length:Int) {
        text.removeSubrange((text.startIndex ..< text.characters.index(text.startIndex, offsetBy: length)))
    }
    
    func parse(_ text:String, rules: [String] = []) -> [TokenBase]{
        var text = text
        while !text.isEmpty {
            let token = getNextToken(text, rules: rules)
            tokens.append(token.token)
            forward(&text, length:token.length)
        }
        return tokens
    }
    
    func chooseParseFunction(_ name:String) -> (RegexMatch) -> TokenBase {
        switch name {
        case "newline":
            return parseNewline
        case "heading":
            return parseHeading
        case "lheading":
            return parseLHeading
        case "fences":
            return parseFences
        case "block_code":
            return parseBlockCode
        case "hrule":
            return parseHRule
        case "block_quote":
            return parseBlockQuote
        case "paragraph":
            return parseParagraph
        case "text":
            return parseText
        default:
            return parseText
        }
    }
    
    func getNextToken(_ text:String, rules: [String]) -> (token:TokenBase, length:Int) {
        var rules = rules
        if rules.isEmpty {
            rules = defaultRules
        }
        for rule in rules {
            if let regex  = grammarRegexMap[rule] {
                if let m = regex.match(text) {
                    let forwardLength = m.group(0).length
                    
                    // Special case
                    if rule == "def_links" {
                        parseDefLinks(m)
                        return (TokenNone(), forwardLength)
                    }
                    
                    if rule == "list_block" {
                        parseListBlock(m)
                        return (TokenNone(), forwardLength)
                    }
                    
                    let parseFunction = chooseParseFunction(rule)
                    let tokenResult = parseFunction(m)
                    return (tokenResult, forwardLength)
                }
            }
        }
        // Move one character. Otherwise may case infinate loop
        return (TokenBase(type: " ", text: text.substring(to: text.characters.index(text.startIndex, offsetBy: 1))), 1)
    }
    
    func parseNewline(_ m: RegexMatch) -> TokenBase {
        let length = m.group(0).length
        if length > 1 {
            return NewLine()
        }
        return TokenNone()
    }
    func parseHeading(_ m: RegexMatch) -> TokenBase {
        return Heading(text: m.group(2), level: m.group(1).length)
    }
    
    func parseLHeading(_ m: RegexMatch) -> TokenBase {
        let level = m.group(2) == "=" ? 1 : 2;
        return Heading(text: m.group(1), level: level)
    }
    
    func parseFences(_ m: RegexMatch) -> TokenBase {
        return BlockCode(text: m.group(3), lang: m.group(2))
    }
    
    func parseBlockCode(_ m: RegexMatch) -> TokenBase {
        var code = String(m.group(0))!
        let pattern = Regex(pattern: "^ {4}")
        if let match = pattern.match(code) {
            code.removeSubrange(match.range())
        }
        return BlockCode(text: code, lang: "")
    }
    
    func parseHRule(_ m: RegexMatch) -> TokenBase {
        return HRule()
    }
    
    func parseBlockQuote(_ m: RegexMatch) -> TokenBase {
        let start = BlockQuote(type: "blockQuoteStart", text: "")
        tokens.append(start)
        let cap = m.group(0)
        
        let pattern = Regex(pattern: "^ *> ?")
        var newCap = ""
        
        // NSRegularExpressoin doesn't support replacement in multilines
        // We have to manually split the captured String into multiple lines
        let lines = cap.components(separatedBy: "\n")
        for (_, var everyMatch) in lines.enumerated() {
            if let match = pattern.match(everyMatch) {
                everyMatch.removeSubrange(match.range())
                newCap += everyMatch + "\n"
            }
        }
        _ = self.parse(newCap)
        return BlockQuote(type: "blockQuoteEnd", text: "")
    }
    
    func parseListBlock(_ m: RegexMatch) {
        let bull = m.group(2)
        let ordered = bull.range(of: ".") != nil
        tokens.append(ListBlock(type: "listBlockStart", ordered: ordered))
        let caps = m._str.components(separatedBy: "\n")
        let loose_list_regex = Regex(pattern: "\\n\\n(?!\\s*$)")
        
        var loose = false
        if loose_list_regex.match(m._str) != nil {
            loose = true
        }
        for cap in caps {
            processListItem(cap, bull: bull, loose:loose)
        }
        tokens.append(ListBlock(type: "listBlockEnd", ordered: ordered))
    }
    
    func processListItem(_ cap: String, bull: String, loose: Bool=false) {
        if trimWhitespace(cap).isEmpty {
            return
        }
        let list_item_regex = self.grammarRegexMap["list_item"]!
        
        if let caps = list_item_regex.match(cap) {
            var text = caps.group(0)
            let list_bullet_regex = self.grammarRegexMap["list_bullet"]!
            if let m = list_bullet_regex.match(text) {
                text.removeSubrange(m.range())
            }
            if loose {
                tokens.append(LooseListItem(type: "looseListItemStart"))
            } else {
                tokens.append(ListItem(type: "listItemStart"))
            }
            _ = self.parse(text, rules: listRules)
        }
        if loose {
            tokens.append(LooseListItem(type: "looseListItemEnd"))
        } else {
            tokens.append(ListItem(type: "listItemEnd"))
        }
    }
    
    func parseDefLinks(_ m: RegexMatch) {
        let key = keyify(m.group(1))
        definedLinks[key] = [
            "link": m.group(2),
            "title": m.matchedString.count > 3 ? m.group(3) : ""
        ]
    }
    
    func parseParagraph(_ m: RegexMatch) -> TokenBase {
        let text = m.group(1)
        return Paragraph(text: text)
    }
    
    func parseText(_ m: RegexMatch) -> TokenBase {
        return TokenBase(type: "text", text: m.group(0))
    }
}

class InlineParser {
    var links = [String:[String:String]]()
    var grammarNameMap = [Regex:String]()
    var grammarList = [Regex]()
    var inLink = false
    
    init() {
        // Backslash escape
        addGrammar("escape", regex:Regex(pattern: "^\\\\([\\\\`*{}\\[\\]()#+\\-.!_>~|])")) // \* \+ \! ...
        addGrammar("autolink", regex: Regex(pattern :"^<([^ >]+(@|:\\/)[^ >]+)>"))
        addGrammar("url", regex: Regex(pattern :"^(https?:\\/\\/[^\\s<]+[^<.,:;\"\')\\]\\s])"))
        addGrammar("tag", regex: Regex(pattern: "^<!--[\\s\\S]*?-->|^<\\/\\w+>|^<\\w+[^>]*?>")) // html tag
        addGrammar("link", regex: Regex(pattern: "^!?\\[((?:\\[[^^\\]]*\\]|[^\\[\\]]|\\](?=[^\\[]*\\]))*)\\]\\(\\s*<?([\\s\\S]*?)>?(?:\\s+[\'\"]([\\s\\S]*?)[\'\"])?\\s*\\)"))
        addGrammar("reflink", regex: Regex(pattern: "^!?\\[((?:\\[[^^\\]]*\\]|[^\\[\\]]|\\](?=[^\\[]*\\]))*)\\]\\s*\\[([^^\\]]*)\\]"))
        addGrammar("nolink", regex: Regex(pattern: "^!?\\[((?:\\[[^\\]]*\\]|[^\\[\\]])*)\\]"))
        addGrammar("double_emphasis", regex: Regex(pattern: "^_{2}(.+?)_{2}(?!_)|^\\*{2}(.+?)\\*{2}(?!\\*)"))
        addGrammar("emphasis", regex: Regex(pattern: "^\\b_((?:__|.)+?)_\\b|^\\*((?:\\*\\*|.)+?)\\*(?!\\*)"))
        addGrammar("code", regex: Regex(pattern: "^(`+)\\s*(.*?[^`])\\s*\\1(?!`)"))
        addGrammar("linebreak", regex: Regex(pattern: "^ {2,}\\n(?!\\s*$)"))
        addGrammar("strikethrough", regex: Regex(pattern: "^~~(?=\\S)(.*?\\S)~~"))
        addGrammar("text", regex: Regex(pattern: "^[\\s\\S]+?(?=[\\\\<!\\[_*`~]|https?://| {2,}\n|$)"))
    }
    
    func addGrammar(_ name:String, regex:Regex) {
        grammarNameMap[regex] = name
        grammarList.append(regex)
    }
    
    func forward(_ text:inout String, length:Int) {
        text.removeSubrange((text.startIndex ..< text.characters.index(text.startIndex, offsetBy: length)))
    }
    
    func parse(_ text:inout String) {
        var result = ""
        while !text.isEmpty {
            let token = getNextToken(text)
            result += token.token.render()
            forward(&text, length:token.length)
        }
        text = result
    }
    
    
    func chooseOutputFunctionForGrammar(_ name:String) -> (RegexMatch) -> TokenBase {
        switch name {
        case "escape":
            return outputEscape
        case "autolink":
            return outputAutoLink
        case "link":
            return outputLink
        case "url":
            return outputURL
        case "tag":
            return outputTag
        case "reflink":
            return outputRefLink
        case "nolink":
            return outputNoLink
        case "double_emphasis":
            return outputDoubleEmphasis
        case "emphasis":
            return outputEmphasis
        case "code":
            return outputCode
        case "linebreak":
            return outputLineBreak
        case "strikethrough":
            return outputStrikeThrough
        case "text":
            return outputText
        default:
            return outputText
        }
    }
    
    func getNextToken(_ text:String) -> (token:TokenBase, length:Int) {
        for regex in grammarList {
            if let m = regex.match(text) {
                let name = grammarNameMap[regex]! // Name won't be nil
                let forwardLength = m.group(0).length
                
                let parseFunction = chooseOutputFunctionForGrammar(name)
                let tokenResult = parseFunction(m)
                if tokenResult is TokenNone {
                    continue
                }
                return (tokenResult, forwardLength)
            }
        }
        return (TokenBase(type: " ", text: text.substring(to: text.characters.index(text.startIndex, offsetBy: 1))) , 1)
    }
    
    func outputEscape(_ m: RegexMatch) -> TokenBase {
        return TokenBase(type: "text", text: m.group(1))
    }
    
    func outputAutoLink(_ m :RegexMatch) -> TokenBase {
        let link = m.group(1)
        var isEmail = false
        if m.group(2) == "@" {
            isEmail = true
        }
        return AutoLink(link: link, isEmail: isEmail)
    }
    func outputTag(_ m: RegexMatch) -> TokenBase {
        let text = m.group(0)
        let lowerText = text.lowercased()
        if lowerText.hasPrefix("<a ") {
            self.inLink = true
        }
        if lowerText.hasPrefix("</a>") {
            self.inLink = false
        }
        return TokenBase(type: "tag", text: text)
    }
    
    func outputURL(_ m: RegexMatch) -> TokenBase {
        let link = m.group(1)
        if self.inLink {
            return TokenEscapedText(type: "text", text: link)
        } else {
            return AutoLink(link: link, isEmail: false)
        }
    }
    
    func outputLink(_ m: RegexMatch) -> TokenBase {
        return processLink(m, link: m.group(2), title: m.group(3))
    }
    
    func outputRefLink(_ m: RegexMatch) -> TokenBase {
        let key = keyify(m.group(2).isEmpty ? m.group(1) : m.group(2))
        if let ret = links[key] {
            // If links[key] exists, the link and title won't be nil
            // We can safely unwrap it
            return processLink(m, link: ret["link"]!, title: ret["title"]!)
        } else {
            return TokenNone()
        }
    }
    
    func outputNoLink(_ m: RegexMatch) -> TokenBase {
        let key = keyify(m.group(1))
        if let ret = self.links[key] {
            return processLink(m, link: ret["link"]!, title: ret["title"]!)
        } else {
            return TokenNone()
        }
    }
    
    func processLink(_ m: RegexMatch, link: String, title: String) -> TokenBase {
        let text = m.group(1)
        return Link(title: title, link: link, text: text)
    }
    
    func outputDoubleEmphasis(_ m: RegexMatch) -> TokenBase {
        var text = m.group(2).isEmpty ? m.group(1) : m.group(2)
        self.parse(&text)
        return DoubleEmphasis(text: text)
    }
    
    func outputEmphasis(_ m: RegexMatch) -> TokenBase {
        var text = m.group(2).isEmpty ? m.group(1) : m.group(2)
        self.parse(&text)
        return Emphasis(text: text)
    }
    
    func outputCode(_ m: RegexMatch) -> TokenBase {
        return InlineCode(text: m.group(2))
    }
    
    func outputLineBreak(_ m: RegexMatch) -> TokenBase {
        return LineBreak()
    }
    
    func outputStrikeThrough(_ m: RegexMatch) -> TokenBase {
        return StrikeThrough(text: m.group(1))
    }
    
    func outputText(_ m: RegexMatch) -> TokenBase {
        return TokenEscapedText(type: "text", text: m.group(0))
    }
}

let blockParser = BlockParser()
let inlineParser = InlineParser()

public func markdown(_ text:String) -> String {
    // Clean up
    blockParser.tokens = [TokenBase]()
    blockParser.definedLinks = [String:[String:String]]()
    inlineParser.links = [String:[String:String]]()
    return parse(text)
}

private func needInLineParsing(_ token: TokenBase) -> Bool {
    return token.type == "text" || token.type == "heading" || token.type == "paragraph"
}

private func parse(_ text:String) -> String {
    var result = String()
    let tokens = blockParser.parse(preprocessing(text))
    // Setup deflinks
    inlineParser.links = blockParser.definedLinks
    for token in tokens {
        if needInLineParsing(token) {
            inlineParser.parse(&token.text)
        }
        result += token.render()
    }
    return result
}


