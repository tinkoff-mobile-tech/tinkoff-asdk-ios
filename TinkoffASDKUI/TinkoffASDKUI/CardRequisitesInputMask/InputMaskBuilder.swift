//
//

import Foundation

public class InputMaskBuilder {
    public enum InputMaskBuildError: Error {
        case wrongFormat
    }

    func build(formatString string: String) throws -> InputState {
        let sanitizedFormat: String = try FormatSanitizer().sanitize(formatString: string)

        return try build(sanitizedFormat, valueable: false, fixed: false)
    }
}

private extension InputMaskBuilder {
    func build(_ string: String, valueable: Bool, fixed _: Bool) throws -> InputState {
        guard let char: Character = string.first else {
            return EOLState()
        }

        if char == "[" {
            return try build(String(string.dropFirst()), valueable: true, fixed: false)
        }

        if char == "]" {
            return try build(String(string.dropFirst()), valueable: false, fixed: false)
        }

        if valueable {
            if char == "0" {
                return ValueState(
                    child: try build(String(string.dropFirst()), valueable: true, fixed: false)
                )
            }

            throw InputMaskBuildError.wrongFormat
        }

        return FreeState(child: try build(String(string.dropFirst()), valueable: false, fixed: false),
                         ownCharacter: char)
    }
}
