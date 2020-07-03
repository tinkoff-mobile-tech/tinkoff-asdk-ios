//
//

import Foundation

/// Model object that represents a set of actions that should take place when transition from one `InputState` to another occurs.
struct Next {

	/// Next `InputState` of the `InputMask`
	let state: InputState

	/// Insert a character into the resulting formatted string.
	let insert: Character?

	/// Pass to the next character of the input string.
	let pass: Bool

	/// Add character to the extracted value string.
	/// Value is extracted from the user input string.
	let value: Character?

}
