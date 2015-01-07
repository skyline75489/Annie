//
//  Regex.swift
//  swift-playground
//
//  Created by skyline on 15/1/5.
//  Copyright (c) 2015年 skyline. All rights reserved.
//

import Foundation

class Regex : Hashable, Equatable{
    private var _re:NSRegularExpression?
    var _pattern:String
    var _matches:RegexMatch?
    var _error:NSError?
    var hashValue: Int {
        get {
            return self._pattern.hash
        }
    }
    
    init(pattern:String) {
        _pattern = pattern
        _re = NSRegularExpression(pattern: _pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &_error)
    }
    
    func match(str:String) -> RegexMatch? {
        if let re = _re {
            _matches = RegexMatch(str:str, matches: re.matchesInString(str, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, countElements(str))))
            if _matches?.matchCount > 0 {
                return _matches
            }
            else {
                return nil
            }
        }
        return nil
    }
}

func == (lhs: Regex, rhs: Regex) -> Bool {
    return lhs._pattern == rhs._pattern
}


class RegexMatch  {
    private var _m:[AnyObject]?
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
            let matches = _m as [NSTextCheckingResult]
            for match in matches  {
                rangeCount = match.numberOfRanges
                for i in 0..<match.numberOfRanges {
                    let range = match.rangeAtIndex(i)
                    if range.location > countElements(_str) {
                        rangeCount--
                        continue;
                    }
                    start.append(advance(_str.startIndex, range.location))
                    end.append(advance(start.last!, range.length))
                    let r = _str.substringWithRange(Range<String.Index>(start: start.last!, end: end.last!))
                    matchedString.append(r)
                }
            }
        }
    }
    
    func range() -> Range<String.Index> {
        return Range<String.Index>(start: self.start[0], end: self.end[0])
    }
    
    func range(index:Int) -> Range<String.Index> {
        return Range<String.Index>(start: self.start[index], end: self.end[index])
    }
    
    func group(index:Int) -> String {
        // Index out of bound
        if index > rangeCount + 1 {
            return ""
        }
        return matchedString[index]
    }
}