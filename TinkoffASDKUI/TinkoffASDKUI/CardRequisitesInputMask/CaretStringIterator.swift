//
//

import Foundation

class CaretStringIterator {
    private let caretString: CaretString
    private var currentIndex: String.Index

    /// Constructor
    ///
    /// - parameter caretString: `CaretString` object, over which the iterator is going to iterate.
    ///
    /// - returns: Initialized `CaretStringIterator` pointing at the beginning of provided `CaretString.string`
    init(caretString: CaretString) {
        self.caretString = caretString
        currentIndex = self.caretString.string.startIndex
    }

    /// Inspect, whether `CaretStringIterator` has reached `CaretString.caretPosition` or not.
    /// - returns: `true`, if current iterator position is less than or equal to `CaretString.caretPosition`
    func beforeCaret() -> Bool {
        let startIndex: String.Index = caretString.string.startIndex
        let currentIndex: Int = caretString.string.distance(from: startIndex, to: self.currentIndex)
        let caretPosition: Int = caretString.string.distance(from: startIndex, to: caretString.caretPosition)

        return self.currentIndex <= caretString.caretPosition || (currentIndex == 0 && caretPosition == 0)
    }

    /// Iterate over the `CaretString.string`
    ///
    /// - postcondition: Iterator position is moved to the next symbol.
    ///
    /// - returns: Current symbol. If the iterator reached the end of the line, returns `nil`.
    func next() -> Character? {
        if currentIndex >= caretString.string.endIndex {
            return nil
        }

        let character: Character = caretString.string[currentIndex]
        currentIndex = caretString.string.index(after: currentIndex)

        return character
    }
}
