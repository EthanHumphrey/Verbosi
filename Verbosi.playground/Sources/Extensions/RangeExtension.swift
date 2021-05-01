//
//  RangeExtension.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/16/21.
//

import Foundation

extension Range {
    func overlaps(with secondRange: Range) -> Bool {
        return self.lowerBound <= secondRange.upperBound && secondRange.lowerBound <= self.upperBound
    }
    
    func overlaps(with ranges: [Range]) -> Bool {
        for range in ranges {
            if overlaps(range) {
                return true
            }
        }
        return false
    }
    
    func removing(_ range: Range) -> Range {
        if range.overlaps(self) {
            if range.lowerBound == self.lowerBound {
                return range.upperBound ..< self.upperBound
            }
            else {
                return self.lowerBound ..< range.lowerBound
            }
        }
        else {
            return self
        }
    }
    
    func removing(_ ranges: [Range]) -> Range {
        var newRange = self
        for range in ranges {
            newRange = newRange.removing(range)
        }
        return newRange
    }
}
