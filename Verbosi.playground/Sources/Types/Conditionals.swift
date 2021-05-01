//
//  Conditionals.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/7/21.
//  Copyright © 2021 Ethan Humphrey. All rights reserved.
//

import Foundation

class Conditionals {
    
    static let conditionalsArray = ["and", "or", "equals", "not equals", "less than", "greater than", "less than or equal to", "greater than or equal to"]
    
    static func getConditionalType(_ expression: String) -> ConditionalType {
        for i in 0 ..< conditionalsArray.count {
            let conditional = conditionalsArray[i]
            if expression == conditional {
                return ConditionalType(rawValue: i + 1)!
            }
        }
        return .none
    }
    
    static func performConditional(_ conditional: ConditionalType, left: Any, right: Any) -> Bool? {
        if let leftString = left as? String, let rightString = right as? String {
            switch conditional {
            case .equal:
                return leftString.lowercased() == rightString.lowercased()
            case .notEqual:
                return leftString != rightString
            case .lessThan:
                return leftString < rightString
            case .greaterThan:
                return leftString > rightString
            case .lessThanEqualTo:
                return leftString <= rightString
            case .greaterThanEqualTo:
                return leftString >= rightString
            default:
                return nil
            }
        }
        else if let leftInt = left as? Int, let rightInt = right as? Int {
            switch conditional {
            case .equal:
                return leftInt == rightInt
            case .notEqual:
                return leftInt != rightInt
            case .lessThan:
                return leftInt < rightInt
            case .greaterThan:
                return leftInt > rightInt
            case .lessThanEqualTo:
                return leftInt <= rightInt
            case .greaterThanEqualTo:
                return leftInt >= rightInt
            default:
                return nil
            }
        }
        else if let leftBool = left as? Bool, let rightBool = right as? Bool {
            switch conditional {
            case .equal:
                return leftBool == rightBool
            case .notEqual:
                return leftBool != rightBool
            case .and:
                return leftBool && rightBool
            case .or:
                return leftBool || rightBool
            default:
                return nil
            }
        }
        return nil
    }
    
    static func getConditionalString(_ conditional: ConditionalType) -> String {
        return conditionalsArray[conditional.rawValue - 1]
    }
    
    static func hasConditional(_ expression: String) -> Bool {
        return conditionalsArray.contains(where: expression.contains)
    }
    
    enum ConditionalType: Int {
        case none
        case and
        case or
        case equal
        case notEqual
        case lessThan
        case greaterThan
        case lessThanEqualTo
        case greaterThanEqualTo
    }
}
