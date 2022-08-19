//
//

import Foundation

class EOLState: InputState {
    convenience init() {
        self.init(child: nil)
    }

    override init(child _: InputState?) {
        super.init(child: nil)
    }

    override func nextState() -> InputState {
        return self
    }

    override func accept(character _: Character) -> Next? {
        return nil
    }

    override var debugDescription: String {
        return "EOL"
    }
}
