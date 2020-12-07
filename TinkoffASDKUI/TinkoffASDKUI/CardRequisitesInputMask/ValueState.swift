//
//

import Foundation

/// Represents mandatory characters in square brackets [].
/// Returns accepted characters as an extracted value.
class ValueState: InputState {
    func accepts(character char: Character) -> Bool {
        return CharacterSet.decimalDigits.isMember(character: char)
    }

    override func accept(character char: Character) -> Next? {
        if !accepts(character: char) {
            return nil
        }

        return Next(state: nextState(), insert: char, pass: true, value: char)
    }

    ///
    /// - parameter child: next ```InputState```
    /// - returns: Initialized ```ValueState``` instance.
    init(child: InputState) {
        super.init(child: child)
    }

    override var debugDescription: String {
        return "[0] -> " + (child != nil ? child!.debugDescription : "nil")
    }
}
