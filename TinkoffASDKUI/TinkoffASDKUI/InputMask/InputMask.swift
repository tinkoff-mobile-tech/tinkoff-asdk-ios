//
//

import Foundation

public class InputMask: CustomDebugStringConvertible, CustomStringConvertible {
    public struct Result: CustomDebugStringConvertible, CustomStringConvertible {
        /// Formatted text with updated caret position.
        public let formattedText: CaretString

        /// Value, extracted from formatted text according to mask format.
        public let extractedValue: String

        /// Calculated absolute affinity value between the mask format and input text.
        public let affinity: Int

        /// User input is complete.
        public let complete: Bool

        public var debugDescription: String {
            return "FORMATTED TEXT: \(formattedText)\nEXTRACTED VALUE: \(extractedValue)\nAFFINITY: \(affinity)\nCOMPLETE: \(complete)"
        }

        public var description: String {
            return debugDescription
        }
    }

    private let initialState: InputState
    private static var cache: [String: InputMask] = [:]

    /// Constructor.
    ///
    /// - parameter format: mask format.
    ///
    /// - returns: Initialized ```InputMask``` instance.
    ///
    /// - throws: ```CompilerError``` if format string is incorrect.
    public required init(format: String) throws {
        initialState = try InputMaskBuilder().build(formatString: format)
    }

    /// Constructor.
    ///
    /// Operates over own `InputMask` cache where initialized ```InputMask``` objects are stored under corresponding format key:
    /// ```[format : mask]```
    ///
    /// - returns: Previously cached ```InputMask``` object for requested format string. If such it doesn't exist in cache, the
    /// object is constructed, cached and returned.
    public static func getOrCreate(withFormat format: String) throws -> InputMask {
        if let cachedMask: InputMask = cache[format] {
            return cachedMask
        } else {
            let mask: InputMask = try InputMask(format: format)
            cache[format] = mask

            return mask
        }
    }

    /// Apply mask to the user input string.
    ///
    /// - parameter toText: user input string with current cursor position
    /// - returns: Formatted text with extracted value an adjusted cursor position.
    public func apply(toText text: CaretString, autocomplete: Bool = false) -> Result {
        let iterator = CaretStringIterator(caretString: text)

        var affinity = 0
        var extractedValue = ""
        var modifiedString = ""
        var modifiedCaretPosition: Int =
            text.string.distance(from: text.string.startIndex, to: text.caretPosition)

        var state: InputState = initialState
        var beforeCaret: Bool = iterator.beforeCaret()
        var character: Character? = iterator.next()

        while let char: Character = character {
            if let next: Next = state.accept(character: char) {
                state = next.state
                modifiedString += nil != next.insert ? String(next.insert!) : ""
                extractedValue += nil != next.value ? String(next.value!) : ""
                if next.pass {
                    beforeCaret = iterator.beforeCaret()
                    character = iterator.next()
                    affinity += 1
                } else {
                    if beforeCaret, next.insert != nil {
                        modifiedCaretPosition += 1
                    }
                    affinity -= 1
                }
            } else {
                if iterator.beforeCaret() {
                    modifiedCaretPosition -= 1
                }
                beforeCaret = iterator.beforeCaret()
                character = iterator.next()
                affinity -= 1
            }
        }

        while autocomplete, beforeCaret, let next: Next = state.autocomplete() {
            state = next.state
            modifiedString += nil != next.insert ? String(next.insert!) : ""
            extractedValue += nil != next.value ? String(next.value!) : ""
            if next.insert != nil {
                modifiedCaretPosition += 1
            }
        }

        return Result(
            formattedText: CaretString(
                string: modifiedString,
                caretPosition: modifiedString.index(modifiedString.startIndex, offsetBy: modifiedCaretPosition)
            ),
            extractedValue: extractedValue,
            affinity: affinity,
            complete: noMandatoryCharactersLeftAfterState(state)
        )
    }

    /// Generate placeholder.
    ///
    /// - returns: Placeholder string.
    public func placeholder() -> String {
        return appendPlaceholder(withState: initialState, placeholder: "")
    }

    /// Minimal length of the text inside the field to fill all mandatory characters in the mask.
    ///
    /// - returns: Minimal satisfying count of characters inside the text field.
    public func acceptableTextLength() -> Int {
        return countStates(ofTypes: [FreeState.self, ValueState.self])
    }

    /// Maximal length of the text inside the field.
    ///
    /// - returns: Total available count of mandatory and optional characters inside the text field.
    public func totalTextLength() -> Int {
        return countStates(ofTypes: [FreeState.self, ValueState.self])
    }

    /// Minimal length of the extracted value with all mandatory characters filled.
    ///
    /// - returns: Minimal satisfying count of characters in extracted value.
    public func acceptableValueLength() -> Int {
        var state: InputState? = initialState
        var length = 0
        while let nextState: InputState = state, !(state is EOLState) {
            if nextState is ValueState {
                length += 1
            }
            state = nextState.child
        }

        return length
    }

    /// Maximal length of the extracted value.
    ///
    /// - returns: Total available count of mandatory and optional characters for extracted value.
    public func totalValueLength() -> Int {
        var state: InputState? = initialState
        var length = 0
        while let nextState: InputState = state, !(state is EOLState) {
            if nextState is ValueState {
                length += 1
            }
            state = nextState.child
        }

        return length
    }

    public var debugDescription: String {
        return initialState.debugDescription
    }

    public var description: String {
        return debugDescription
    }
}

private extension InputMask {
    func appendPlaceholder(withState state: InputState?, placeholder: String) -> String {
        guard let state: InputState = state
        else { return placeholder }

        if state is EOLState {
            return placeholder
        }

        if let state = state as? FreeState {
            return appendPlaceholder(withState: state.child, placeholder: placeholder + String(state.ownCharacter))
        }

        if let state = state as? ValueState {
            return appendPlaceholder(withState: state.child, placeholder: placeholder + "0")
        }

        return placeholder
    }

    func noMandatoryCharactersLeftAfterState(_ state: InputState) -> Bool {
        if state is EOLState {
            return true
        } else if state is FreeState || state is ValueState {
            return false
        } else {
            return noMandatoryCharactersLeftAfterState(state.nextState())
        }
    }
}

private extension InputMask {
    func countStates(ofTypes stateTypes: [InputState.Type]) -> Int {
        var state: InputState? = initialState
        var length = 0
        while let newState: InputState = state, !(state is EOLState) {
            for stateType in stateTypes {
                if type(of: newState) == stateType {
                    length += 1
                }
            }

            state = newState.child
        }

        return length
    }
}
