//
//

import Foundation

/// State of the mask, similar to the state in regular expressions.
/// Each state represents a character from the mask format string.
class InputState: CustomDebugStringConvertible, CustomStringConvertible {

	/// Next `InputState`.
	let child: InputState?

	/// Abstract method.
	///
	/// Defines, whether the state accepts user input character or not, and which actions should take place when the
	/// character is accepted.
	///
	/// - parameter character: character from the user input string.
	/// - returns: `Next` object instance with a set of actions that should take place when the user input character is accepted.
	///
	/// - throws: Fatal error, if the method is not implemeted.
	/* abstract */ func accept(character char: Character) -> Next? {
		fatalError("accept(character:) method is abstract")
	}

	func autocomplete() -> Next? {
		return nil
	}

	func nextState() -> InputState {
		return self.child!
	}

	init(child: InputState?) {
		self.child = child
	}

	// MARK: CustomDebugStringConvertible

	var debugDescription: String {
		get {
			return "BASE -> " + (nil != self.child ? self.child!.debugDescription : "nil")
		}
	}

	// MARK: CustomStringConvertible

	var description: String {
		get {
			return self.debugDescription
		}
	}

}
