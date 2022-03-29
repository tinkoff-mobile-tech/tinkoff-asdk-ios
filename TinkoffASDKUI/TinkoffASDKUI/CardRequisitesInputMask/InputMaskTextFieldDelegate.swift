//
//

import Foundation
import UIKit

@IBDesignable
open class InputMaskTextFieldDelegate: MaskedTextFieldDelegate {
    fileprivate var _affineFormats: [String]

    public var affineFormats: [String] {
        get {
            return _affineFormats
        }

        set(newFormats) {
            _affineFormats = newFormats
        }
    }

    public init(primaryFormat: String, affineFormats: [String]) {
        self._affineFormats = affineFormats
        super.init(format: primaryFormat)
    }

    override public init(format: String) {
        self._affineFormats = []
        super.init(format: format)
    }

    override open func put(text: String, into field: UITextField) {
        let mask: InputMask = pickMask(forText: text, caretPosition: text.endIndex, autocomplete: autocomplete)

        let result: InputMask.Result = mask.apply(toText: CaretString(string: text, caretPosition: text.endIndex),
                                                  autocomplete: autocomplete)

        field.text = result.formattedText.string

        let position: Int = result.formattedText.string.distance(from: result.formattedText.string.startIndex, to: result.formattedText.caretPosition)

        setCaretPosition(position, inField: field)
        listener?.textField?(field, didFillMask: result.complete, extractValue: result.extractedValue)
    }

    override open func deleteText(inRange range: NSRange, inField field: UITextField) -> (String, Bool) {
        let text: String = replaceCharacters(inText: field.text, range: range, withCharacters: "")
        let mask: InputMask = pickMask(forText: text, caretPosition: text.index(text.startIndex, offsetBy: range.location), autocomplete: false)

        let result: InputMask.Result = mask.apply(toText: CaretString(string: text, caretPosition: text.index(text.startIndex, offsetBy: range.location)),
                                                  autocomplete: false)

        field.text = result.formattedText.string
        setCaretPosition(range.location, inField: field)

        return (result.extractedValue, result.complete)
    }

    override open func modifyText(inRange range: NSRange, inField field: UITextField, withText text: String) -> (String, Bool) {
        let updatedText: String = replaceCharacters(inText: field.text, range: range, withCharacters: text)

        let mask: InputMask = pickMask(forText: updatedText, caretPosition: updatedText.index(updatedText.startIndex, offsetBy: caretPosition(inField: field) + text.count), autocomplete: autocomplete)

        let result: InputMask.Result = mask.apply(toText: CaretString(string: updatedText, caretPosition: updatedText.index(updatedText.startIndex, offsetBy: caretPosition(inField: field) + text.count)),
                                                  autocomplete: autocomplete)

        field.text = result.formattedText.string
        let position: Int = result.formattedText.string.distance(from: result.formattedText.string.startIndex, to: result.formattedText.caretPosition)
        setCaretPosition(position, inField: field)

        return (result.extractedValue, result.complete)
    }

    override open var debugDescription: String {
        return _affineFormats.reduce(mask.debugDescription) { (debugDescription: String, affineFormat: String) -> String in
            // swiftlint: disable force_try
            try! debugDescription + "\n" + InputMask.getOrCreate(withFormat: affineFormat).debugDescription
            // swiftlint: enable force_try
        }
    }
}

internal extension InputMaskTextFieldDelegate {
    func pickMask(forText text: String, caretPosition: String.Index, autocomplete: Bool) -> InputMask {
        let primaryAffinity: Int = calculateAffinity(ofMask: mask, forText: text, caretPosition: caretPosition, autocomplete: autocomplete)

        var masks: [(InputMask, Int)] = affineFormats.map { (affineFormat: String) -> (InputMask, Int) in
            // swiftlint: disable force_try
            let mask: InputMask = try! InputMask.getOrCreate(withFormat: affineFormat)
            // swiftlint: enable force_try
            let affinity: Int = self.calculateAffinity(ofMask: mask, forText: text, caretPosition: caretPosition, autocomplete: autocomplete)

            return (mask, affinity)
        }

        masks.sort { (left: (InputMask, Int), right: (InputMask, Int)) -> Bool in
            left.1 > right.1
        }

        var insertIndex: Int = -1

        for (index, maskAffinity) in masks.enumerated() {
            if primaryAffinity >= maskAffinity.1 {
                insertIndex = index
                break
            }
        }

        if insertIndex >= 0 {
            masks.insert((mask, primaryAffinity), at: insertIndex)
        } else {
            masks.append((mask, primaryAffinity))
        }

        return masks.first!.0
    }

    func calculateAffinity(ofMask mask: InputMask, forText text: String, caretPosition: String.Index, autocomplete: Bool) -> Int {
        return mask.apply(toText: CaretString(string: text, caretPosition: caretPosition),
                          autocomplete: autocomplete).affinity
    }
}
