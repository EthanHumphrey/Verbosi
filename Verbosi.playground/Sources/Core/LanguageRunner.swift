//
//  LanguageRunner.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/7/21.
//  Copyright © 2021 Ethan Humphrey. All rights reserved.
//

import Foundation

class LanguageRunner {
    
    var globalScope: Scope!
    var mainInstructions = Instructions()
    
    weak var delegate: LanguageRunnerDelegate?
    
    public init(instructions: String) {
        mainInstructions = Instructions(instructions.split(separator: "\n"))
        globalScope = Scope()
    }
    
    func runCode() {
        findFunctions(from: mainInstructions, in: globalScope)
        _ = runCode(instructions: mainInstructions, scope: globalScope)
    }
    
    func resumeCode() {
        _ = runCode(instructions: mainInstructions, scope: globalScope)
    }
    
    func runCode(instructions: Instructions, scope: Scope) -> Any? {
        instructionLoop: while instructions.instructions.count > 0 {
            let thisInstruction = instructions.instructions.first!
            let expressionReturn = evaluateExpression(String(thisInstruction), scope: scope).flattened()
            
            if let (expressionEndReturn, returnedValue) = expressionReturn as? (ExpressionEndType, Any) {
                switch expressionEndReturn {
                case .returnValue:
                    return returnedValue
                default:
                    break
                }
            }
            else if let expressionEndReturn = expressionReturn as? ExpressionEndType {
                switch expressionEndReturn {
                case .gettingInput:
                    return ExpressionEndType.gettingInput
                case .startIf:
                    if let conditionalString = RegexParser.parseSingleOutput(thisInstruction, regexPattern: #"if (.+) \{"#) {
                        let conditional = evaluateExpression(conditionalString, scope: scope).flattened() as? Bool ?? false
                        let (instructionsArray, lastIndex) = getCodeBetweenCurlys(instructions, searchForElse: true)
                        
                        let ifScope = Scope(parent: scope)
                        
                        if conditional {
                            if let trueInstructions = instructionsArray.first {
                                let returnValue = runCode(instructions: trueInstructions, scope: ifScope)
                                if let returnEndType = returnValue as? ExpressionEndType, returnEndType == .breakLoop || returnEndType == .gettingInput {
                                    return returnEndType
                                }
                            }
                        }
                        else if instructionsArray.count > 1 {
                            let returnValue = runCode(instructions: instructionsArray[1], scope: ifScope)
                            if let returnEndType = returnValue as? ExpressionEndType, returnEndType == .breakLoop || returnEndType == .gettingInput {
                                return returnEndType
                            }
                        }
                        instructions.instructions.removeSubrange(0...lastIndex)
                        continue instructionLoop
                    }
                case .startRepeat:
                    let (instructionsArray, lastIndex) = getCodeBetweenCurlys(instructions)
                    if let conditionalString = RegexParser.parseSingleOutput(thisInstruction, regexPattern: #"repeat until (.+) \{"#),
                       let trueInstructions = instructionsArray.first
                    {
                        let loopScope = Scope(parent: scope)
                        while !(evaluateExpression(conditionalString, scope: scope).flattened() as? Bool ?? false) {
                            let returnValue = runCode(instructions: trueInstructions.uniqueInstructions(), scope: loopScope)
                            if let returnEndType = returnValue as? ExpressionEndType, returnEndType == .breakLoop || returnEndType == .gettingInput {
                                return returnEndType
                            }
                        }
                    }
                    else if let numTimesString = RegexParser.parseSingleOutput(thisInstruction, regexPattern: #"repeat (.+) times \{"#) {
                        let numTimesResult = evaluateExpression(numTimesString, scope: scope).flattened()
                        let loopScope = Scope(parent: scope)
                        if let numTimes = numTimesResult as? Int, let trueInstructions = instructionsArray.first {
                            for _ in 0 ..< numTimes {
                                let returnValue = runCode(instructions: trueInstructions.uniqueInstructions(), scope: loopScope)
                                if let returnEndType = returnValue as? ExpressionEndType, returnEndType == .breakLoop || returnEndType == .gettingInput {
                                    return returnEndType
                                }
                            }
                        }
                    }
                    instructions.instructions.removeSubrange(0...lastIndex)
                    continue instructionLoop
                case .startForEach:
                    let (instructionsArray, lastIndex) = getCodeBetweenCurlys(instructions)
                    if let (indexVariableName, lowerBoundString, upperBoundString) = RegexParser.parseTripleOutput(thisInstruction, regexPattern: #"for each (\w+) in (.+) to (.+) \{"#),
                       let lowerBound = evaluateExpression(lowerBoundString, scope: scope).flattened() as? Int,
                       let upperBound = evaluateExpression(upperBoundString, scope: scope).flattened() as? Int,
                       let trueInstructions = instructionsArray.first
                    {
                        let loopScope = Scope(parent: scope)
                        var i = lowerBound
                        while (i <= upperBound) {
                            scope.setVariable(indexVariableName, newValue: i)
                            let returnValue = runCode(instructions: trueInstructions.uniqueInstructions(), scope: loopScope)
                            if let returnEndType = returnValue as? ExpressionEndType {
                                if returnEndType == .breakLoop {
                                    break
                                }
                                else if returnEndType == .gettingInput {
                                    return returnValue
                                }
                            }
                            if let changedI = scope.getVariable(indexVariableName) as? Int {
                                i = changedI
                            }
                            i += 1
                        }
                    }
                    else if let (itemVariableName, arrayName) = RegexParser.parseDualOutput(thisInstruction, regexPattern: #"for each (\w+) in (.+) \{"#),
                            let array = scope.getVariable(arrayName) as? VerbosiArray,
                            let trueInstructions = instructionsArray.first
                    {
                        let loopScope = Scope(parent: scope)
                        for (index, item) in array.array.enumerated() {
                            scope.setVariable(itemVariableName, newValue: item as Any)
                            let returnValue = runCode(instructions: trueInstructions.uniqueInstructions(), scope: loopScope)
                            if let returnEndType = returnValue as? ExpressionEndType {
                                if returnEndType == .breakLoop {
                                    break
                                }
                                else if returnEndType == .gettingInput {
                                    return returnValue
                                }
                            }
                            array.array[index] = scope.getVariable(itemVariableName)
                        }
                    }
                                
                    instructions.instructions.removeSubrange(0...lastIndex)
                    continue instructionLoop
                case .breakLoop:
                    return ExpressionEndType.breakLoop
                case .none, .returnValue, .startFunction:
                    break
                }
            }
            if !instructions.instructions.isEmpty {
                instructions.instructions.removeFirst()
            }
        }
        return nil
    }
    
    func findFunctions(from instructions: Instructions, in scope: Scope) {
        var ranges = [ClosedRange<Int>]()
        for (index, instruction) in instructions.instructions.enumerated() {
            let stringRanges = getRangesOfStrings(instruction)
            if let (functionName, functionParameterNames) = RegexParser.parseDualOutput(instruction, regexPattern: #"function (\w+)\((.+)\) \{"#, stringRanges: stringRanges) {
                let parameterNames = functionParameterNames.split(separator: ",").map({ (substring) -> String in
                    return String(substring)
                })
                
                let (instructionsArray, lastIndex) = getCodeBetweenCurlys(instructions, startIndex: index)
                
                if let functionInstructions = instructionsArray.first {
                    let function = VerbosiFunction(instructions: functionInstructions, parameterNames: parameterNames, languageRunner: self)
                    
                    scope.functionDict[functionName] = function
                    
                    ranges.append(index...lastIndex)
                }
            }
            else if let functionName = RegexParser.parseSingleOutput(instruction, regexPattern: #"function (\w+)\(\) \{"#, stringRanges: stringRanges) {
                let (instructionsArray, lastIndex) = getCodeBetweenCurlys(instructions, startIndex: index)
                
                if let functionInstructions = instructionsArray.first {
                    let function = VerbosiFunction(instructions: functionInstructions, languageRunner: self)
                    scope.functionDict[functionName] = function
                    ranges.append(index...lastIndex)
                }
            }
        }
        for i in 0 ..< ranges.count {
            let range = ranges[ranges.count - i - 1]
            instructions.instructions.removeSubrange(range)
        }
    }
    
    func getCodeBetweenCurlys(_ code: Instructions, startIndex: Int = 0, searchForElse: Bool = false) -> ([Instructions], Int) {
        var startBrackets = 0
        var endBrackets = 0
        var elseIndex = 0
        var elseStartIndex = 0
        var subInstructionsArray = [[String](), [String]()]
        var totalEndIndex = 0
        for instructionIndex in startIndex ..< code.instructions.count {
            let thisSubInstruction = code.instructions[instructionIndex]
            if thisSubInstruction.contains("{") {
                startBrackets += 1
            }
            if thisSubInstruction.contains("}") {
                endBrackets += 1
            }
            if startBrackets == endBrackets {
                if thisSubInstruction.contains("{") && thisSubInstruction.contains("}") {
                    let firstIndexOfForwardCurly = thisSubInstruction.firstIndex(of: "{")!
                    let lastIndexOfBackwardCurly = thisSubInstruction.lastIndex(of: "}")!
                    
                    subInstructionsArray[elseIndex].append(
                        String(thisSubInstruction[
                                thisSubInstruction.index(after: firstIndexOfForwardCurly)..<lastIndexOfBackwardCurly
                            ]
                    ))
                }
                if searchForElse && instructionIndex + 1 != code.instructions.count && code.instructions[instructionIndex + 1].contains("else") {
                    elseIndex += 1
                    elseStartIndex = instructionIndex + 1
                }
                else {
                    totalEndIndex = instructionIndex
                    break
                }
            }
            else if instructionIndex != 0 && elseStartIndex != instructionIndex {
                subInstructionsArray[elseIndex].append(String(thisSubInstruction))
            }
        }
        var instructionsArray = [Instructions]()
        subInstructionsArray.forEach { (array) in
            if array.count > 0 {
                instructionsArray.append(Instructions(array))
            }
        }
        return (instructionsArray, totalEndIndex)
    }

    var tempInput: [Any] = []
    
    func getInput(numInputs: Int) {
        if numInputs > 0 {
            delegate?.getInput(completion: { (stringInput) in
                if let intInput = Int(stringInput) {
                    self.tempInput.append(intInput)
                }
                else if let doubleInput = Double(stringInput) {
                    self.tempInput.append(doubleInput)
                }
                else {
                    self.tempInput.append(stringInput)
                }
                self.getInput(numInputs: numInputs - 1)
            })
        }
        else {
            resumeCode()
        }
    }
    
    func getRangesOfStrings(_ expression: String) -> [Range<String.Index>] {
        var startQuoteIndex: String.Index?
        var ranges = [Range<String.Index>]()
        for (i, char) in expression.enumerated() {
            if char == "\"" {
                let index = expression.index(expression.startIndex, offsetBy: i)
                if startQuoteIndex != nil {
                    if expression[expression.index(before: index)] != "\\" {
                        ranges.append(startQuoteIndex!..<index)
                        startQuoteIndex = nil
                    }
                }
                else {
                    startQuoteIndex = index
                }
            }
        }
        return ranges
    }

    func evaluateExpression(_ expression: String, scope: Scope) -> Any? {
        let trimmedExpression = expression.trimmingCharacters(in: .whitespaces)
        let stringRanges = getRangesOfStrings(trimmedExpression)
        
        if trimmedExpression.contains("getInput()") && tempInput.count != trimmedExpression.components(separatedBy: "getInput()").count - 1 {
            getInput(numInputs: trimmedExpression.components(separatedBy: "getInput()").count - 1)
            return ExpressionEndType.gettingInput
        }
        
        if let ifRange = trimmedExpression.range(of: "if"), !ifRange.overlaps(with: stringRanges) {
            return ExpressionEndType.startIf
        }
        else if let repeatRange = trimmedExpression.range(of: "repeat"), !repeatRange.overlaps(with: stringRanges) {
            return ExpressionEndType.startRepeat
        }
        else if let forEachRange = trimmedExpression.range(of: "for each"), !forEachRange.overlaps(with: stringRanges) {
            return ExpressionEndType.startForEach
        }
        else if let functionRange = trimmedExpression.range(of: "function"), !functionRange.overlaps(with: stringRanges) {
            return ExpressionEndType.startFunction
        }
        else if let breakRange = trimmedExpression.range(of: "break loop"), !breakRange.overlaps(with: stringRanges) {
            return ExpressionEndType.breakLoop
        }
        else if let (variableName, subExpression) = RegexParser.parseDualOutput(trimmedExpression, regexPattern: #"set (\w+) to (.+)"#, stringRanges: stringRanges) {
            // Variable Assignment: set (variableName) to (expression)
            let variableValue = evaluateExpression(subExpression, scope: scope).flattened()
            scope.setVariable(variableName, newValue: variableValue as Any)
            return variableValue
        }
        else if let (arrayName, indexExpression, subExpression) = RegexParser.parseTripleOutput(trimmedExpression, regexPattern: #"set (\w+)\[(.+)\] to (.+)"#, stringRanges: stringRanges) {
            let variableValue = evaluateExpression(subExpression, scope: scope).flattened()
            if let array = scope.getVariable(arrayName) as? VerbosiArray,
               let arrayIndex = evaluateExpression(indexExpression, scope: scope).flattened() as? Int
            {
                array.array[arrayIndex] = variableValue
            }
            return scope.getVariable(arrayName)
        }
        else if let subExpression = RegexParser.parseSingleOutput(trimmedExpression, regexPattern: #"show (.+)"#, stringRanges: stringRanges) {
            // Display: show (expression)
            let subExpressionResult = evaluateExpression(subExpression, scope: scope).flattened()
            if let array = subExpressionResult as? VerbosiArray {
                var arrayString = "["
                for (index, element) in array.array.enumerated() {
                    arrayString.append(String(describing: element.flattened() ?? "nil"))
                    if index != array.array.endIndex - 1 {
                        arrayString.append(", ")
                    }
                }
                arrayString.append("]")
                delegate?.displayOutput(arrayString)
            }
            else {
                delegate?.displayOutput(String(describing: subExpressionResult.flattened() ?? "nil"))
            }
        }
        else if let subExpression = RegexParser.parseSingleOutput(trimmedExpression, regexPattern: #"return (.+)"#, stringRanges: stringRanges) {
            // Return: return value
            return (ExpressionEndType.returnValue, evaluateExpression(subExpression, scope: scope).flattened())
        }
        else if let (valueExpression, listName, indexExpression) = RegexParser.parseTripleOutput(trimmedExpression, regexPattern: #"insert (.+) into (\w+) at (.+)"#, stringRanges: stringRanges) {
            // Insert Into Array: insert (value) into (list) at (index)
            if let list = scope.getVariable(listName) as? VerbosiArray,
               let index = evaluateExpression(indexExpression, scope: scope).flattened() as? Int,
               let value = evaluateExpression(valueExpression, scope: scope).flattened(),
               0 <= index && index < list.array.count
            {
                list.array.insert(value, at: index)
                return list
            }
            else if let string = scope.getVariable(listName) as? String,
                    let index = evaluateExpression(indexExpression, scope: scope).flattened() as? Int,
                    let value = evaluateExpression(valueExpression, scope: scope).flattened(),
                    0 <= index && index < string.count
            {
                let leftString = String(string[string.startIndex..<string.index(string.startIndex, offsetBy: index)])
                let rightString = String(string[string.index(string.startIndex, offsetBy: index)..<string.endIndex])
                let newString = Operations.performOperation(.add, left: Operations.performOperation(.add, left: leftString, right: value) as! String, right: rightString)
                scope.setVariable(listName, newValue: newString as Any)
                return newString
            }
        }
        else if let (stringExpression, startIndexExpression, endIndexExpression) = RegexParser.parseTripleOutput(trimmedExpression, regexPattern: #"substring of (.+) from (.+) to (.+)"#, stringRanges: stringRanges) {
            // Substring: substring of (string) from (startIndex) to (endIndex)
            if let string = evaluateExpression(stringExpression, scope: scope).flattened() as? String,
                    let startIndex = evaluateExpression(startIndexExpression, scope: scope).flattened() as? Int,
                    let endIndex = evaluateExpression(endIndexExpression, scope: scope).flattened() as? Int,
                    0 <= startIndex && startIndex <= endIndex && endIndex < string.count
            {
                let leftIndex = string.index(string.startIndex, offsetBy: startIndex)
                let rightIndex = string.index(string.startIndex, offsetBy: endIndex)
                let newString = string[leftIndex ..< rightIndex]
                return newString
            }
        }
        else if let (valueExpression, listName) = RegexParser.parseDualOutput(trimmedExpression, regexPattern: #"append (.+) to (\w+)"#, stringRanges: stringRanges) {
            // Append to Array: append (value) to (list)
            if let list = scope.getVariable(listName) as? VerbosiArray, let value = evaluateExpression(valueExpression, scope: scope).flattened() {
                list.array.append(value)
                return list
            }
            else if let string = scope.getVariable(listName) as? String, let value = evaluateExpression(valueExpression, scope: scope).flattened() {
                if let newString = Operations.performOperation(.add, left: string, right: value) {
                    scope.setVariable(listName, newValue: newString)
                    return newString
                }
            }
        }
        else if let (listName, indexExpression) = RegexParser.parseDualOutput(trimmedExpression, regexPattern: #"remove from (\w+) at (.+)"#, stringRanges: stringRanges) {
            // Remove from array: remove from (list) at (index)
            if let list = scope.getVariable(listName) as? VerbosiArray, let
                index = evaluateExpression(indexExpression, scope: scope).flattened() as? Int,
               0 <= index && index < list.array.count
            {
                list.array.remove(at: index)
                return list
            }
            else if var string = scope.getVariable(listName) as? String,
                    let index = evaluateExpression(indexExpression, scope: scope).flattened() as? Int,
                    0 <= index && index < string.count
            {
                string.remove(at: string.index(string.startIndex, offsetBy: index))
                scope.setVariable(listName, newValue: string)
                return string
            }
        }
        else if let listName = RegexParser.parseSingleOutput(trimmedExpression, regexPattern: #"length of (\w+)"#, stringRanges: stringRanges) {
            // Array Length: length of (list)
            if let list = scope.getVariable(listName) as? VerbosiArray {
                return list.array.count
            }
            else if let string = scope.getVariable(listName) as? String {
                return string.count
            }
        }
        else if let conditionExpression = RegexParser.parseSingleOutput(trimmedExpression, regexPattern: #"not (?!equals)(.+)"#, stringRanges: stringRanges) {
            // Not conditional: not (condition)
            let condition = evaluateExpression(conditionExpression, scope: scope).flattened()
            return !(condition as? Bool ?? true)
        }
        else if let (firstNum, secondNum) = RegexParser.parseDualOutput(trimmedExpression, regexPattern: #"random between (.+) and (.+)"#, stringRanges: stringRanges) {
            // Random Number Generator: random between (int) and (int)
            let leftExpressionResult = evaluateExpression(firstNum, scope: scope).flattened()
            let rightExpressionResult = evaluateExpression(secondNum, scope: scope).flattened()
            if let from = leftExpressionResult as? Int, let to = rightExpressionResult as? Int, from <= to {
                return Int.random(in: from ... to)
            }
        }
        else if let (leftExpression, rightExpression) = RegexParser.parseDualOutput(trimmedExpression, regexPattern: #"((.+) not equals (.+))|((.+) equals (.+))|((.+) greater than or equal to (.+))|((.+) less than or equal to (.+))|((.+) greater than (.+))|((.+) less than (.+))|((?!between )(.+) and (.+))|((.+) or (.+))"#, stringRanges: stringRanges) {
            /* Perform Conditional:
                a equals b
                a not equals b
                a greater than b
                a less than b
                a greater than or equal to b
                a less than or equal to b
                a and b
                a or b
            */
            if let entireConditionalRange = trimmedExpression.range(of: #"\Q"# + leftExpression + #"\E (not equals)|(equals)|(greater than or equal to)|(less than or equal to)|(greater than)|(less than)|(and)|(or) \Q"# + rightExpression + #"\E"#, options: .regularExpression),
               let conditionalRange = trimmedExpression[entireConditionalRange].range(of: "(not equals)|(equals)|(greater than or equal to)|(less than or equal to)|(greater than)|(less than)|(and)|(or)", options: .regularExpression)
            {
                let conditionalString = String(trimmedExpression[conditionalRange]).trimmingCharacters(in: .whitespaces)
                let conditional = Conditionals.getConditionalType(conditionalString)
                
                let leftResult = evaluateExpression(leftExpression, scope: scope).flattened()
                let rightResult = evaluateExpression(rightExpression, scope: scope).flattened()
                return Conditionals.performConditional(conditional, left: leftResult as Any, right: rightResult as Any)
            }
        }
        else if let (leftExpression, rightExpression) = RegexParser.parseDualOutput(trimmedExpression, regexPattern: #"((.+) plus (.+))|((.+) minus (.+))|((.+) multiply (.+))|((.+) divide (.+))|((.+) mod (.+))"#, stringRanges: stringRanges) {
            /* Perform operations:
                a plus b
                a minus b
                a multiply b
                a divide b
                a mod b
            */
            if let entireOperationRange = trimmedExpression.range(of: #"\Q"# + leftExpression + #"\E (plus)|(minus)|(multiply)|(divide)|(mod) \Q"# + rightExpression + #"\E"#, options: .regularExpression),
               let operationRange = trimmedExpression[entireOperationRange].range(of: "(plus)|(minus)|(multiply)|(divide)|(mod)", options: .regularExpression)
            {
                let operationString = String(trimmedExpression[operationRange]).trimmingCharacters(in: .whitespaces)
                let operation = Operations.getOperationType(operationString)
                
                let leftResult = evaluateExpression(leftExpression, scope: scope).flattened()
                let rightResult = evaluateExpression(rightExpression, scope: scope).flattened()
                return Operations.performOperation(operation, left: leftResult as Any, right: rightResult as Any)
            }
        }
        else if let (arrayName, valueExpression) = RegexParser.parseDualOutput(trimmedExpression, regexPattern: #"(\w+) contains (.+)"#) {
            if let array = scope.getVariable(arrayName) as? VerbosiArray,
               let value = evaluateExpression(valueExpression, scope: scope).flattened()
            {
                return array.array.contains { (element) -> Bool in
                    if let comparableElement = element as? String, let comparableValue = value as? String {
                        return comparableElement == comparableValue
                    }
                    else if let comparableElement = element as? Int, let comparableValue = value as? Int {
                        return comparableElement == comparableValue
                    }
                    else if let comparableElement = element as? Bool, let comparableValue = value as? Bool {
                        return comparableElement == comparableValue
                    }
                    return false
                }
            }
            else if let string = scope.getVariable(arrayName) as? String,
                    let stringValue = evaluateExpression(valueExpression, scope: scope).flattened() as? String {
                return string.contains(stringValue)
            }
        }
        else if let (arrayName, indexExpression) = RegexParser.parseDualOutput(trimmedExpression, regexPattern: #"(\w+)\[(.+)\]"#, stringRanges: stringRanges) {
            // Get Array Value: arrayName[index]
            if let array = scope.getVariable(arrayName) as? VerbosiArray,
               let arrayIndex = evaluateExpression(indexExpression, scope: scope).flattened() as? Int,
               0 <= arrayIndex && arrayIndex < array.array.count
            {
                return array.array[arrayIndex]
            }
            else if let string = scope.getVariable(arrayName) as? String,
                    let stringIndex = evaluateExpression(indexExpression, scope: scope).flattened() as? Int,
                    0 <= stringIndex && stringIndex < string.count
            {
                return String(string[string.index(string.startIndex, offsetBy: stringIndex)])
            }
        }
        else if let arrayExpression = RegexParser.parseSingleOutput(trimmedExpression, regexPattern: #"\[(.+)\]"#, stringRanges: stringRanges) {
            // New Array: [value1, value2, value3]
            let subExpressions = arrayExpression.split(separator: ",")
            var tempArray = [Any]()
            for expression in subExpressions {
                tempArray.append(evaluateExpression(String(expression), scope: scope).flattened() as Any)
            }
            return VerbosiArray(tempArray)
        }
        else if trimmedExpression.contains("[]") {
            return VerbosiArray([])
        }
        else if let (functionName, parametersString) = RegexParser.parseDualOutput(trimmedExpression, regexPattern: #"(\w+)\((.+)\)"#) {
            // Run Function: functionName(parameter1, parameter2)
            let parametersStringArray = parametersString.split(separator: ",")
            let parametersArray = parametersStringArray.map { (expression) -> Any in
                return self.evaluateExpression(String(expression), scope: scope).flattened() as Any
            }
            return scope.runFunction(functionName, parameters: parametersArray)
        }
        else if let functionName = RegexParser.parseSingleOutput(trimmedExpression, regexPattern: #"(\w+)\(\)"#) {
            // Run Function: functionName()
            if functionName == "getInput" {
                // Return Input collected previously: getInput()
                let thisInput = tempInput.first
                tempInput.removeFirst()
                return thisInput
            }
            else {
                return scope.runFunction(functionName)
            }
        }
        else if let string = RegexParser.parseSingleOutput(trimmedExpression, regexPattern: #""(.+)""#) {
            // Create String: "text"
            return string
        }
        else if trimmedExpression.contains("\"\"") {
            return String("")
        }
        else if let number = Int(trimmedExpression) {
            // Return a number
            return number
        }
        else if trimmedExpression == "true" || trimmedExpression == "false" {
            // Return a boolean
            return Bool(trimmedExpression)
        }
        else {
            // Get a variable
            return scope.getVariable(trimmedExpression)
        }
        return nil
    }
}

protocol LanguageRunnerDelegate: class {
    func displayOutput(_ output: String)
    func getInput(completion: @escaping (_ input: String) -> Void)
}
