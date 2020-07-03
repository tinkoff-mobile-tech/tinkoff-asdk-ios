//
//

import Foundation

class EOLState: InputState {

	convenience init() {
		self.init(child: nil)
	}

	override init(child: InputState?) {
		super.init(child: nil)
	}

	override func nextState() -> InputState {
		return self
	}

	override func accept(character char: Character) -> Next? {
		return nil
	}

	override var debugDescription: String {
		get {
			return "EOL"
		}
	}

}
