import Foundation
import AppKit

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            self.isAutomaticQuoteSubstitutionEnabled = false
        }
    }
}
