//
//

import Foundation

class FreeState: InputState {
    let ownCharacter: Character

    override func accept(character char: Character) -> Next? {
        if ownCharacter == char {
            return Next(state: nextState(), insert: char, pass: true, value: nil)
        } else {
            return Next(state: nextState(), insert: ownCharacter, pass: false, value: nil)
        }
    }

    override func autocomplete() -> Next? {
        return Next(state: nextState(), insert: ownCharacter, pass: false, value: nil)
    }

    /// Constructor.
    ///
    /// - parameter child: next ```InputState```
    /// - parameter ownCharacter: represented "free" character
    ///
    /// - returns: Initialized ```FreeState``` instance.
    init(child: InputState, ownCharacter: Character) {
        self.ownCharacter = ownCharacter
        super.init(child: child)
    }

    override var debugDescription: String {
        return "\(ownCharacter) -> " + (child != nil ? child!.debugDescription : "nil")
    }
}
