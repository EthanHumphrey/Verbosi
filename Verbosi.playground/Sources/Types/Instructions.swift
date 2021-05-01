//
//  Instructions.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/7/21.
//  Copyright © 2021 Ethan Humphrey. All rights reserved.
//

import Foundation

class Instructions {
    var instructions: [String] = []
    init() {
        self.instructions = []
    }
    init(_ instructions: [String.SubSequence]) {
        for instruction in instructions {
            self.instructions.append(String(instruction))
        }
    }
    init(_ instructions: [String]) {
        self.instructions = instructions
    }
    
    func uniqueInstructions() -> Instructions {
        return Instructions(self.instructions)
    }
}
