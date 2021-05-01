//
//  OptionalExtension.swift
//  Verbosi
//
//  Created by Ethan Humphrey on 4/18/21.
//

import Foundation

extension Optional: Flattenable {
    func flattened() -> Any? {
        switch self {
        case .some(let x as Flattenable): return x.flattened()
        case .some(let x): return x
        case .none: return nil
        }
    }
}

protocol Flattenable {
  func flattened() -> Any?
}
