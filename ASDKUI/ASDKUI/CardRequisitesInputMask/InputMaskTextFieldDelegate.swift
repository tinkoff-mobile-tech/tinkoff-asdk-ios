//
//

import Foundation
import UIKit


@IBDesignable
open class InputMaskTextFieldDelegate: MaskedTextFieldDelegate {

	fileprivate var _affineFormats: [String]

	public var affineFormats: [String] {
		get {
			return self._affineFormats
		}

		set(newFormats) {
			self._affineFormats = newFormats
		}
	}

	public init(primaryFormat: String, affineFormats: [String]) {
		self._affineFormats = affineFormats
		super.init(format: primaryFormat)
	}

	public override init(format: String) {
		self._affineFormats = []
		super.init(format: format)
	}

	open override func put(text: String, into field: UITextField) {
		let mask: InputMask = self.pickMask(forText: text, caretPosition: text.endIndex, autocomplete: self.autocomplete)

		let result: InputMask.Result = mask.apply(
			toText: CaretString(string: text, caretPosition: text.endIndex),
			autocomplete: self.autocomplete
		)

		field.text = result.formattedText.string

		let position: Int = result.formattedText.string.distance(from: result.formattedText.string.startIndex, to: result.formattedText.caretPosition)

		self.setCaretPosition(position, inField: field)
		self.listener?.textField?(field, didFillMask: result.complete, extractValue: result.extractedValue)
	}

	override open func deleteText(inRange range: NSRange, inField field: UITextField) -> (String, Bool) {
		let text: String = self.replaceCharacters(inText: field.text, range: range, withCharacters: "")
		let mask: InputMask = self.pickMask(forText: text, caretPosition: text.index(text.startIndex, offsetBy: range.location), autocomplete: false)

		let result: InputMask.Result = mask.apply(
			toText: CaretString(string: text, caretPosition: text.index(text.startIndex, offsetBy: range.location)),
			autocomplete: false
		)

		field.text = result.formattedText.string
		self.setCaretPosition(range.location, inField: field)

		return (result.extractedValue, result.complete)
	}

	override open func modifyText(inRange range: NSRange, inField field: UITextField, withText text: String) -> (String, Bool) {
		let updatedText: String = self.replaceCharacters(inText: field.text, range: range, withCharacters: text)

		let mask: InputMask = self.pickMask(forText: updatedText, caretPosition: updatedText.index(updatedText.startIndex, offsetBy: self.caretPosition(inField: field) + text.count), autocomplete: self.autocomplete)

		let result: InputMask.Result = mask.apply(
			toText: CaretString(string: updatedText, caretPosition: updatedText.index(updatedText.startIndex, offsetBy: self.caretPosition(inField: field) + text.count)),
			autocomplete: self.autocomplete
		)

		field.text = result.formattedText.string
		let position: Int = result.formattedText.string.distance(from: result.formattedText.string.startIndex, to: result.formattedText.caretPosition)
		self.setCaretPosition(position, inField: field)

		return (result.extractedValue, result.complete)
	}

	open override var debugDescription: String {
		get {
			return self._affineFormats.reduce(self.mask.debugDescription) { (debugDescription: String, affineFormat: String) -> String in
				return try! debugDescription + "\n" + InputMask.getOrCreate(withFormat: affineFormat).debugDescription
			}
		}
	}

}


internal extension InputMaskTextFieldDelegate {

	func pickMask(forText text: String, caretPosition: String.Index, autocomplete: Bool) -> InputMask {
		let primaryAffinity: Int = self.calculateAffinity(ofMask: self.mask, forText: text, caretPosition: caretPosition, autocomplete: autocomplete)

		var masks: [(InputMask, Int)] = self.affineFormats.map { (affineFormat: String) -> (InputMask, Int) in
			let mask: InputMask = try! InputMask.getOrCreate(withFormat: affineFormat)
			let affinity: Int  = self.calculateAffinity(ofMask: mask, forText: text, caretPosition: caretPosition, autocomplete: autocomplete)

			return (mask, affinity)
		}

		masks.sort { (left: (InputMask, Int), right: (InputMask, Int)) -> Bool in
			return left.1 > right.1
		}

		var insertIndex: Int = -1

		for (index, maskAffinity) in masks.enumerated() {
			if primaryAffinity >= maskAffinity.1 {
				insertIndex = index
				break
			}
		}

		if insertIndex >= 0 {
			masks.insert((self.mask, primaryAffinity), at: insertIndex)
		} else {
			masks.append((self.mask, primaryAffinity))
		}

		return masks.first!.0
	}

	func calculateAffinity(ofMask mask: InputMask, forText text: String, caretPosition: String.Index, autocomplete: Bool) -> Int {
		return mask.apply(
			toText: CaretString(string: text, caretPosition: caretPosition),
			autocomplete: autocomplete
		).affinity
	}

}
