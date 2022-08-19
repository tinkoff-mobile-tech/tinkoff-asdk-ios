//
//

import Foundation

/// Utility extension to make `NSCharacterSet` interact with `Character` instances.
extension CharacterSet {
    /// Implements `NSCharacterSet.characterIsMember(:unichar)` for `Character` instances.
    func isMember(character: Character) -> Bool {
        let string = String(character)
        for char in string.unicodeScalars {
            if !contains(char) {
                return false
            }
        }

        return true
    }
}
