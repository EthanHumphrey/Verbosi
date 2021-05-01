//
//  RegexParser.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/7/21.
//  Copyright © 2021 Ethan Humphrey. All rights reserved.
//

import Foundation

class RegexParser {
    
    static func parseSingleOutput(_ expression: String, regexPattern: String, stringRanges: [Range<String.Index>]? = nil) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
            
            var firstCapture: String?

            let nsRange = NSRange(expression.startIndex ..< expression.endIndex, in: expression)
            regex.enumerateMatches(in: expression, options: [], range: nsRange) { (match, _, stop) in
                guard let match = match else { return }
                
                var firstGroupIndex = 1
                
                if match.numberOfRanges > 2 {
                    for i in 1 ..< match.numberOfRanges {
                        if let _ = Range(match.range(at: i), in: expression) {
                            firstGroupIndex = i + 1
                            break
                        }
                    }
                }
                
                if let matchRange = Range(match.range(at: 0), in: expression),
                   let firstCaptureRange = Range(match.range(at: firstGroupIndex), in: expression) {
                    var overlaps = false
                    if stringRanges != nil {
                        let cleansedMatchRange = matchRange.removing(firstCaptureRange)
                        for range in stringRanges! {
                            if range.overlaps(cleansedMatchRange) {
                                overlaps = true
                                break
                            }
                        }
                    }
                    if !overlaps {
                        firstCapture = String(expression[firstCaptureRange])
                    }
                    stop.pointee = true
                }
            }
            if firstCapture != nil {
                return firstCapture!
            }
            else {
                return nil
            }
        }
        catch {
            // TODO: Handle error
            print(error)
        }
        return nil
    }
    
    static func parseDualOutput(_ expression: String, regexPattern: String, stringRanges: [Range<String.Index>]? = nil) -> (String, String)? {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
            
            var firstCapture: String?
            var secondCapture: String?

            let nsRange = NSRange(expression.startIndex ..< expression.endIndex, in: expression)
            regex.enumerateMatches(in: expression, options: [], range: nsRange) { (match, _, stop) in
                guard let match = match else { return }
                
                var firstGroupIndex = 1
                var secondGroupIndex = 2
                
                if match.numberOfRanges > 3 {
                    for i in 1 ..< match.numberOfRanges {
                        if let _ = Range(match.range(at: i), in: expression) {
                            firstGroupIndex = i + 1
                            secondGroupIndex = i + 2
                            break
                        }
                    }
                }
                
                if let matchRange = Range(match.range(at: 0), in: expression),
                   let firstCaptureRange = Range(match.range(at: firstGroupIndex), in: expression),
                   let secondCaptureRange = Range(match.range(at: secondGroupIndex), in: expression)
                {
                    var overlaps = false
                    if stringRanges != nil {
                        let cleansedMatchRange = matchRange.removing([firstCaptureRange, secondCaptureRange])
                        for range in stringRanges! {
                            if range.overlaps(cleansedMatchRange) {
                                overlaps = true
                                break
                            }
                        }
                    }
                    if !overlaps {
                        firstCapture = String(expression[firstCaptureRange])
                        secondCapture = String(expression[secondCaptureRange])
                    }
                    stop.pointee = true
                }
            }
            if firstCapture != nil && secondCapture != nil {
                
                return (firstCapture!, secondCapture!)
            }
            else {
                return nil
            }
        }
        catch {
            // TODO: Handle error
        }
        return nil
    }
    
    static func parseTripleOutput(_ expression: String, regexPattern: String, stringRanges: [Range<String.Index>]? = nil) -> (String, String, String)? {
        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
            
            var firstCapture: String?
            var secondCapture: String?
            var thirdCapture: String?

            let nsRange = NSRange(expression.startIndex ..< expression.endIndex, in: expression)
            regex.enumerateMatches(in: expression, options: [], range: nsRange) { (match, _, stop) in
                guard let match = match else { return }
                
                var firstGroupIndex = 1
                var secondGroupIndex = 2
                var thirdGroupIndex = 3
                
                if match.numberOfRanges > 4 {
                    for i in 1 ..< match.numberOfRanges {
                        if let _ = Range(match.range(at: i), in: expression) {
                            firstGroupIndex = i + 1
                            secondGroupIndex = i + 2
                            thirdGroupIndex = i + 3
                            break
                        }
                    }
                }

                if let matchRange = Range(match.range(at: 0), in: expression),
                   let firstCaptureRange = Range(match.range(at: firstGroupIndex), in: expression),
                   let secondCaptureRange = Range(match.range(at: secondGroupIndex), in: expression),
                   let thirdCaptureRange = Range(match.range(at: thirdGroupIndex), in: expression)
                {
                    var overlaps = false
                    if stringRanges != nil {
                        let cleansedMatchRange = matchRange.removing([firstCaptureRange, secondCaptureRange, thirdCaptureRange])
                        for range in stringRanges! {
                            if range.overlaps(cleansedMatchRange) {
                                overlaps = true
                                break
                            }
                        }
                    }
                    if !overlaps {
                        firstCapture = String(expression[firstCaptureRange])
                        secondCapture = String(expression[secondCaptureRange])
                        thirdCapture = String(expression[thirdCaptureRange])
                    }
                    stop.pointee = true
                }
            }
            if firstCapture != nil && secondCapture != nil && thirdCapture != nil {
                return (firstCapture!, secondCapture!, thirdCapture!)
            }
            else {
                return nil
            }
        }
        catch {
            // TODO: Handle error
        }
        return nil
    }
    
}
