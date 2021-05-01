//
//  Operations.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/7/21.
//  Copyright © 2021 Ethan Humphrey. All rights reserved.
//

import Foundation

class Operations {
    
    static let operatorArray = ["plus", "minus", "multiply", "divide", "mod"]
    
    static func getOperationType(_ expression: String) -> OperationType {
        for i in 0 ..< operatorArray.count {
            let operation = operatorArray[i]
            if expression == operation {
                return OperationType(rawValue: i + 1)!
            }
        }
        return .none
    }
    
    static func performOperation(_ operation: OperationType, left: Any, right: Any) -> Any? {
        if let leftString = left as? String, let rightString = right as? String {
            switch operation {
            case .add:
                return leftString + rightString
            default:
                return nil
            }
        }
        else if let leftString = left as? String, let rightInt = right as? Int {
            switch operation {
            case .add:
                return leftString + String(rightInt)
            default:
                return nil
            }
        }
        else if let leftInt = left as? Int, let rightString = right as? String {
            switch operation {
            case .add:
                return String(leftInt) + rightString
            default:
                return nil
            }
        }
        else if let leftInt = left as? Int, let rightInt = right as? Int {
            switch operation {
            case .add:
                return leftInt + rightInt
            case .subtract:
                return leftInt - rightInt
            case .multiply:
                return leftInt * rightInt
            case .divide:
                return leftInt / rightInt
            case .modulus:
                return leftInt % rightInt
            case .none:
                return nil
            }
        }
        return nil
    }
    
    static func getOperationString(_ operation: OperationType) -> String {
        return operatorArray[operation.rawValue - 1]
    }
    
    static func hasOperation(_ expression: String) -> Bool {
        return operatorArray.contains(where: expression.contains)
    }
    
    enum OperationType: Int {
        case none
        case add
        case subtract
        case multiply
        case divide
        case modulus
    }
}
