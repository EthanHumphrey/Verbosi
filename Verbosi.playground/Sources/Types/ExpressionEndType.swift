//
//  ExpressionEndType.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/7/21.
//  Copyright © 2021 Ethan Humphrey. All rights reserved.
//

import Foundation

enum ExpressionEndType {
    case none
    case gettingInput
    case startIf
    case startRepeat
    case startForEach
    case startFunction
    case returnValue
    case breakLoop
}
