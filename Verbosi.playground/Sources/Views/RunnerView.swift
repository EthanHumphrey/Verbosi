//
//  RunnerView.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/14/21.
//  Copyright © 2021 Ethan Humphrey. All rights reserved.
//

import SwiftUI

public struct RunnerView: View {
    
    public static let hostedView = RunnerView()
    
    @ObservedObject var language = LanguageRunnerWrapper()
    
    @State var code = VerbosiProgram.coinFlip.code
    
    @State var pickerSelection = 0
    
    public var body: some View {
        VStack {
            Picker("Example Program:", selection: $pickerSelection) {
                ForEach(0 ..< VerbosiProgram.programs.count) { index in
                    Text(VerbosiProgram.programs[index].name)
                        .tag(index)
                }
            }
            .onChange(of: pickerSelection, perform: { value in
                code = VerbosiProgram.programs[pickerSelection].code
            })
            .padding()
            
            TextEditor(text: $code)
                .font(.custom("Courier New", size: 15, relativeTo: .body))
                .padding()
                .background(Color(.controlBackgroundColor))
            Button("Run Code") {
                language.runCode(code)
            }
            Text("Console Output:")
            ScrollView {
                HStack {
                    Text(language.outputConsole)
                        .font(.custom("Courier New", size: 15, relativeTo: .body))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding()
            }
            .background(Color(.controlBackgroundColor))
            if language.needsInput {
                HStack {
                    TextField("Input", text: $language.input)
                    Button("Confirm") {
                        language.confirmInput()
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

struct RunnerView_Previews: PreviewProvider {
    static var previews: some View {
        RunnerView()
    }
}
