//
//

import Foundation
import UIKit

///
/// Allows clients to obtain value extracted by the mask from user input.
/// Provides callbacks from listened UITextField.
@objc public protocol MaskedTextFieldDelegateListener: UITextFieldDelegate {
    /// Callback to return extracted value and to signal whether the user has complete input.
    @objc optional func textField(_ textField: UITextField, didFillMask complete: Bool, extractValue value: String)
}

@IBDesignable
open class MaskedTextFieldDelegate: NSObject, UITextFieldDelegate {
    private var _maskFormat: String
    private var _autocomplete: Bool
    private var _autocompleteOnFocus: Bool

    public var mask: InputMask

    @IBInspectable public var maskFormat: String {
        get {
            return _maskFormat
        }

        set(newFormat) {
            _maskFormat = newFormat
            // swiftlint: disable force_try
            mask = try! InputMask.getOrCreate(withFormat: newFormat)
            // swiftlint: enable force_try
        }
    }

    @IBInspectable public var autocomplete: Bool {
        get {
            return _autocomplete
        }

        set(newAutocomplete) {
            _autocomplete = newAutocomplete
        }
    }

    @IBInspectable public var autocompleteOnFocus: Bool {
        get {
            return self._autocompleteOnFocus
        }

        set(newAutocompleteOnFocus) {
            self._autocompleteOnFocus = newAutocompleteOnFocus
        }
    }

    open weak var listener: MaskedTextFieldDelegateListener?

    public init(format: String) {
        _maskFormat = format
        // swiftlint: disable force_try
        mask = try! InputMask.getOrCreate(withFormat: format)
        // swiftlint: enable force_try
        _autocomplete = false
        _autocompleteOnFocus = false
        super.init()
    }

    override public convenience init() {
        self.init(format: "")
    }

    open func put(text: String, into field: UITextField) {
        let result: InputMask.Result = mask.apply(
            toText: CaretString(string: text, caretPosition: text.endIndex),
            autocomplete: _autocomplete
        )

        field.text = result.formattedText.string

        let position: Int =
            result.formattedText.string.distance(from: result.formattedText.string.startIndex, to: result.formattedText.caretPosition)

        setCaretPosition(position, inField: field)
        ///
        listener?.textField?(field, didFillMask: result.complete, extractValue: result.extractedValue)
    }

    /// Maximal length of the text inside the field.
    ///
    /// - returns: Total available count of mandatory and optional characters inside the text field.
    open func placeholder() -> String {
        return mask.placeholder()
    }

    /// Minimal length of the text inside the field to fill all mandatory characters in the mask.
    ///
    /// - returns: Minimal satisfying count of characters inside the text field.
    open func acceptableTextLength() -> Int {
        return mask.acceptableTextLength()
    }

    /// Maximal length of the text inside the field.
    ///
    /// - returns: Total available count of mandatory and optional characters inside the text field.
    open func totalTextLength() -> Int {
        return mask.totalTextLength()
    }

    /// Minimal length of the extracted value with all mandatory characters filled.
    ///
    /// - returns: Minimal satisfying count of characters in extracted value.
    open func acceptableValueLength() -> Int {
        return mask.acceptableValueLength()
    }

    /// Maximal length of the extracted value.
    ///
    /// - returns: Total available count of mandatory and optional characters for extracted value.
    open func totalValueLength() -> Int {
        return mask.totalValueLength()
    }

    // MARK: - UITextFieldDelegate

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let extractedValue: String
        let complete: Bool

        if isDeletion(inRange: range, string: string) {
            (extractedValue, complete) = deleteText(inRange: range, inField: textField)
        } else {
            (extractedValue, complete) = modifyText(inRange: range, inField: textField, withText: string)
        }

        listener?.textField?(textField, didFillMask: complete, extractValue: extractedValue)
        _ = listener?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string)

        return false
    }

    open func deleteText(inRange range: NSRange, inField field: UITextField) -> (String, Bool) {
        let text: String = replaceCharacters(inText: field.text, range: range, withCharacters: "")

        let result: InputMask.Result = mask.apply(
            toText: CaretString(string: text, caretPosition: text.index(text.startIndex, offsetBy: range.location)),
            autocomplete: false
        )

        field.text = result.formattedText.string
        setCaretPosition(range.location, inField: field)

        return (result.extractedValue, result.complete)
    }

    open func modifyText(inRange range: NSRange, inField field: UITextField, withText text: String) -> (String, Bool) {
        let updatedText: String = replaceCharacters(inText: field.text, range: range, withCharacters: text)

        let result: InputMask.Result = mask.apply(
            toText: CaretString(string: updatedText, caretPosition: updatedText.index(updatedText.startIndex, offsetBy: caretPosition(inField: field) + text.count)),
            autocomplete: autocomplete
        )

        field.text = result.formattedText.string
        let position: Int = result.formattedText.string.distance(from: result.formattedText.string.startIndex, to: result.formattedText.caretPosition)
        setCaretPosition(position, inField: field)

        return (result.extractedValue, result.complete)
    }

    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return listener?.textFieldShouldBeginEditing?(textField) ?? true
    }

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        if _autocompleteOnFocus && textField.text!.isEmpty {
            _ = self.textField(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
        }

        listener?.textFieldDidBeginEditing?(textField)
    }

    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return listener?.textFieldShouldEndEditing?(textField) ?? true
    }

    open func textFieldDidEndEditing(_ textField: UITextField) {
        listener?.textFieldDidEndEditing?(textField)
    }

    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let shouldClear: Bool = listener?.textFieldShouldClear?(textField) ?? true
        if shouldClear {
            let result: InputMask.Result = mask.apply(
                toText: CaretString(string: "", caretPosition: "".endIndex),
                autocomplete: autocomplete
            )

            listener?.textField?(textField, didFillMask: result.complete, extractValue: result.extractedValue)
        }

        return shouldClear
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return listener?.textFieldShouldReturn?(textField) ?? true
    }

    override open var debugDescription: String {
        return self.mask.debugDescription
    }

    override open var description: String {
        return debugDescription
    }
}

public extension MaskedTextFieldDelegate {
    @IBOutlet var delegate: NSObject? {
        get {
            return listener as? NSObject
        }

        set(newDelegate) {
            if let listener = newDelegate as? MaskedTextFieldDelegateListener {
                self.listener = listener
            }
        }
    }
}

internal extension MaskedTextFieldDelegate {
    func isDeletion(inRange range: NSRange, string: String) -> Bool {
        return range.length > 0 && string.count == 0
    }

    func replaceCharacters(inText text: String?, range: NSRange, withCharacters newText: String) -> String {
        if let text = text {
            if range.length > 0 {
                let result = NSMutableString(string: text)
                result.replaceCharacters(in: range, with: newText)
                return result as String
            } else {
                let result = NSMutableString(string: text)
                result.insert(newText, at: range.location)
                return result as String
            }
        } else {
            return ""
        }
    }

    func caretPosition(inField field: UITextField) -> Int {
        // Workaround for non-optional `field.beginningOfDocument`, which could actually be nil if field doesn't have focus
        guard field.isFirstResponder
        else {
            return field.text?.count ?? 0
        }

        if let range: UITextRange = field.selectedTextRange {
            let selectedTextLocation: UITextPosition = range.start
            return field.offset(from: field.beginningOfDocument, to: selectedTextLocation)
        } else {
            return 0
        }
    }

    func setCaretPosition(_ position: Int, inField field: UITextField) {
        // Workaround for non-optional `field.beginningOfDocument`, which could actually be nil if field doesn't have focus
        guard field.isFirstResponder else {
            return
        }

        if position > field.text?.count ?? 0 {
            return
        }

        let from: UITextPosition = field.position(from: field.beginningOfDocument, offset: position)!
        let to: UITextPosition = field.position(from: from, offset: 0)!
        field.selectedTextRange = field.textRange(from: from, to: to)
    }
}
