//
//  Scope.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/18/21.
//

import Foundation

class Scope {
    var parentScope: Scope?
    var variableDict: [String : Any] = [:]
    var functionDict: [String : VerbosiFunction] = [:]
    
    init(parent: Scope? = nil) {
        self.parentScope = parent
    }
    
    func getVariable(_ variableName: String) -> Any? {
        var variable: Any? = nil
        if let parent = parentScope {
            variable = parent.getVariable(variableName)
        }
        if variable == nil {
            variable = variableDict[variableName] ?? nil
        }
        return variable
    }
    
    func setVariable(_ variableName: String, newValue: Any) {
        var scope: Scope? = self
        var didSetVariable = false
        while (scope != nil && !didSetVariable) {
            if scope!.variableDict[variableName] != nil {
                scope!.variableDict[variableName] = newValue
                didSetVariable = true
            }
            else {
                scope = scope!.parentScope
            }
        }
        
        if !didSetVariable {
            variableDict[variableName] = newValue
        }
    }
    
    func getFunction(_ functionName: String) -> VerbosiFunction? {
        var function: VerbosiFunction? = nil
        if let parent = parentScope {
            function = parent.getFunction(functionName)
        }
        if function == nil {
            function = functionDict[functionName] ?? nil
        }
        return function
    }
    
    func runFunction(_ functionName: String, parameters: [Any] = []) -> Any? {
        let function = getFunction(functionName)
        return function?.run(parameters: parameters, in: self) ?? nil
    }
}
