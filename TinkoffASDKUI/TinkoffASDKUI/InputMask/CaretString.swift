//
//

import Foundation

/// Model object that represents string with current cursor position.
public struct CaretString: CustomDebugStringConvertible, CustomStringConvertible, Equatable {
    /// Text from the user.
    public let string: String

    /// Cursor position from the input text field.
    public let caretPosition: String.Index

    ///
    /// - parameter string: text from the user.
    /// - parameter caretPosition: cursor position from the input text field.
    public init(string: String, caretPosition: String.Index) {
        self.string = string
        self.caretPosition = caretPosition
    }

    public var debugDescription: String {
        return "STRING: \(string)\nCARET POSITION: \(caretPosition)"
    }

    public var description: String {
        return debugDescription
    }
}

public func == (left: CaretString, right: CaretString) -> Bool {
    return left.caretPosition == right.caretPosition && left.string == right.string
}
