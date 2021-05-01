//
//  LanguageRunnerWrapper.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/14/21.
//  Copyright © 2021 Ethan Humphrey. All rights reserved.
//

import Foundation

class LanguageRunnerWrapper: LanguageRunnerDelegate, ObservableObject {
    
    @Published var outputConsole = ""
    @Published var needsInput = false
    @Published var input = ""
    
    var languageRunner: LanguageRunner!
    
    var tempInputHandler: ((String) -> Void)?
    
    func runCode(_ newCode: String) {
        
        languageRunner = LanguageRunner(instructions: newCode)
        languageRunner.delegate = self
        outputConsole = ""
        DispatchQueue(label: "VerbosiCodeRunner").async {
            self.languageRunner.runCode()
        }
    }
    
    func displayOutput(_ output: String) {
        DispatchQueue.main.async {
            if self.outputConsole == "" {
                self.outputConsole += output
            }
            else {
                self.outputConsole += "\n" + output
            }
        }
    }
    
    func getInput(completion: @escaping (String) -> Void) {
        DispatchQueue(label: "VerbosiCodeRunner").async {
            self.tempInputHandler = completion
            self.needsInput = true
        }
    }
    
    func confirmInput() {
        needsInput = false
        DispatchQueue(label: "VerbosiCodeRunner").async {
            self.tempInputHandler!(self.input)
            self.input = ""
        }
    }
    
}
