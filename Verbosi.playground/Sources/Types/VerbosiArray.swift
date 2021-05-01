//
//  VerbosiArray.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/8/21.
//  Copyright © 2021 Ethan Humphrey. All rights reserved.
//

import Foundation

class VerbosiArray: CustomStringConvertible {
    var array: [Any?]
    init(_ array: [Any?]) {
        self.array = array
    }
    var description: String {
        return array.description
    }
}
