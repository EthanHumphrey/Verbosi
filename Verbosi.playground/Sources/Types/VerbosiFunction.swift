//
//  VerbosiFunction.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/18/21.
//

import Foundation

class VerbosiFunction {
    
    var languageRunner: LanguageRunner!
    let instructions: Instructions!
    var parameterNames: [String]!
    
    init(instructions: Instructions, parameterNames: [String] = [], languageRunner: LanguageRunner) {
        self.instructions = instructions
        self.parameterNames = parameterNames
        self.languageRunner = languageRunner
    }
    
    func run(parameters: [Any], in scope: Scope) -> Any? {
        let functionScope = Scope(parent: scope)
        for (index, parameter) in parameters.enumerated() {
            let parameterName = parameterNames[index]
            functionScope.setVariable(parameterName, newValue: parameter)
        }
        return languageRunner.runCode(instructions: instructions.uniqueInstructions(), scope: functionScope).flattened()
    }
    
}
