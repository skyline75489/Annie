//
//  Regex.swift
//  swift-playground
//
//  Created by skyline on 15/1/5.
//  Copyright (c) 2015年 skyline. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension String {
    var length : Int {
        return self.characters.count
    }
    
    func repeatString(_ n:Int) -> String {
        var result = self
        for _ in 1 ..< n {
            result.append(self)
        }
        return result
    }
    
    fileprivate var WHITESPACE_REGEXP: String {
        return "[\t\n\r\u{11}\u{12} ]"
    }
    
    func lstrip(_ s:String) -> String {
        let re = try! NSRegularExpression(pattern: s, options: NSRegularExpression.Options.caseInsensitive)
        return re.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, self.length), withTemplate: "")
    }
    
    func lstrip() -> String {
        return self.lstrip("^\(self.WHITESPACE_REGEXP)+")
    }
    
    func rstrip(_ s:String) -> String {
        let re = try! NSRegularExpression(pattern: s, options: NSRegularExpression.Options.caseInsensitive)
        return re.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, self.length), withTemplate: "")
    }
    
    func rstrip() -> String {
        return self.rstrip("\(self.WHITESPACE_REGEXP)+$")
    }
}

class Regex : Hashable, Equatable{
    fileprivate var re:NSRegularExpression?
    var pattern:String
    var matches:RegexMatch?
    var hashValue: Int {
        get {
            return self.pattern.hash
        }
    }
    
    init(pattern:String, options: NSRegularExpression.Options=NSRegularExpression.Options.caseInsensitive) {
        self.pattern = pattern
        self.re = try? NSRegularExpression(pattern: self.pattern, options: options)

    }
    
    func match(_ str:String) -> RegexMatch? {
        if let re = self.re {
            self.matches = RegexMatch(str:str, matches: re.matches(in: str, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, str.length)))
            if self.matches?.matchCount > 0 {
                return self.matches
            }
            else {
                return nil
            }
        }
        return nil
    }
}

func == (lhs: Regex, rhs: Regex) -> Bool {
    return lhs.pattern == rhs.pattern
}


class RegexMatch  {
    fileprivate var _m:[AnyObject]?
    var matchedString = [String]()
    var _str:String // String to match against
    var matchCount:Int = 0
    var rangeCount:Int = 0
    var start:[String.Index] = []
    var end:[String.Index] = []
    
    init(str:String, matches:[AnyObject]?) {
        _str = str
        if let _matches = matches {
            _m = _matches
            matchCount = _matches.count
            let matches = _m as! [NSTextCheckingResult]
            for match in matches  {
                rangeCount = match.numberOfRanges
                for i in 0..<match.numberOfRanges {
                    let range = match.rangeAt(i)
                    if range.location > _str.characters.count {
                        rangeCount -= 1
                        continue;
                    }
                    start.append(_str.characters.index(_str.startIndex, offsetBy: range.location))
                    end.append(_str.index(start.last!, offsetBy: range.length))
                    let r = _str.substring(with: (start.last! ..< end.last!))
                    matchedString.append(r)
                }
            }
        }
        _str = self.group(0)
    }
    
    func range() -> Range<String.Index> {
        return (self.start[0] ..< self.end[0])
    }
    
    func range(_ index:Int) -> Range<String.Index> {
        return (self.start[index] ..< self.end[index])
    }
    
    func group(_ index:Int) -> String {
        // Index out of bound
        if index >= matchedString.count {
            return ""
        }
        return matchedString[index]
    }
}
