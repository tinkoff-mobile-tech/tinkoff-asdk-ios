//
//  InputCardRequisitesProtocols.swift
//  ASDKUI
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

public protocol CardRequisitesBrandInfoProtocol {
		
	func cardBrandInfo(numbers: String?, completion: @escaping (_ requisites: String?, _ icon: UIImage?, _ iconSize: CGSize) -> Void)
	
}


protocol CardRequisitesValidatorProtocol {
	
	func validateCardNumber(number: String?) -> Bool
	
	func validateCardExpiredDate(year: Int, month: Int) -> Bool
	
	/// Validate ExpiredDate in format `MMYY`
	func validateCardExpiredDate(value: String?) -> Bool
	
	func validateCardCVC(cvc: String?) -> Bool
	
}


protocol CardRequisitesInputMaskProtocol {
	
	func inputMaskForCardNumber(number: String?) -> String?
	
	func inputMaskForExpiredDate() -> String?
	
	func seriliazeExpiredDate(date: String?) -> (year: Int, month: Int)
	
}

protocol CardRequisitesScanerProtocol: class {
	
	func startScanner(completion: @escaping (_ number: String?, _ yy: Int?, _ mm: Int?) -> Void)
	
}


public class CardRequisites {
	
	public init() {}
	
	enum CardType: Int {
		case unrecognized = 0, mastercard = 1, visa = 3, mir = 4, maestro = 5
	}
	
	func paymentSystemType(number: String?) -> CardType {
		var result: CardType = .unrecognized
		if let prefix = number?.prefix(1) {
			switch String(prefix) {
			case "6":
				result = .maestro
			case "5":
				result = .mastercard
			case "4":
				result = .visa
			case "2":
				result = .mastercard
				if let prefix4 = number?.prefix(4) {
					do {
						let regexp = try NSRegularExpression.init(pattern: "220[0-4]", options: .caseInsensitive)
						let matches = regexp.matches(in: String(prefix4), options: [], range: NSRange(location: 0, length: prefix4.count))
						if matches.count == 1 {
							result = .mir
						}
					} catch { }
				}
				
			default:
				result = .unrecognized
			}
		}
		
		return result
	}
	
	func decimals(value: String) -> String {
		return value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
	}
	
}


class CardRequisitesInputMask: CardRequisites, CardRequisitesInputMaskProtocol {
	
	func inputMaskForCardNumber(number: String?) -> String? {
		var result: String?
		
		if let num = number, num.isEmpty == false {
			switch paymentSystemType(number: num) {
			case .unrecognized, .mastercard, .visa, .mir:
				result = "[0000] [0000] [0000] [0000]"
			case .maestro:
				result = "[00000000] [00000000000]"
			}
		}
		
		return result
	}
	
	func inputMaskForExpiredDateSeparator() -> String {
		return "/"
	}
	
	func inputMaskForExpiredDate() -> String? {
		return "[00]\(inputMaskForExpiredDateSeparator())[00]"
	}
	
	func seriliazeExpiredDate(date: String?) -> (year: Int, month: Int) {
		if let components = date?.components(separatedBy: self.inputMaskForExpiredDateSeparator()), components.count == 2 {
			if let year = Int(components[1]), let month = Int(components[0]) {
				return (year: year, month: month)
			}
		}
		
		return (year: 0, month: 0)
	}
	
}


class CardRequisitesValidator: CardRequisites, CardRequisitesValidatorProtocol {
	
	private let minimumBinCharacters: Int = 16
	
	private func luhnCheck(value: String) -> Bool {
		var sum = 0
		let reversedCharacters = value.reversed().map { String($0) }
		for (idx, element) in reversedCharacters.enumerated() {
			guard let digit = Int(element) else { return false }
			switch ((idx % 2 == 1), digit) {
			case (true, 9):
				sum += 9
			case (true, 0...8):
				sum += (digit * 2) % 9
			default:
				sum += digit
			}
		}
		
		return sum % 10 == 0
	}
	
	func validateCardNumber(number: String?) -> Bool {
		if let num = number, num.isEmpty == false {
			let numbers = decimals(value: num)
			if numbers.count >= self.minimumBinCharacters {
				return self.luhnCheck(value: numbers)
			}
		}
		
		return false
	}
	
	func validateCardExpiredDate(year: Int, month: Int) -> Bool {
		let date = Date.init()
		let calendar = Calendar.current
		
		let yearNow = calendar.component(.year, from: date)
		let monthNow = calendar.component(.month, from: date)
		
		return (100 * (2000 + year) + month >= 100 * yearNow + monthNow)
	}
	
	func validateCardExpiredDate(value: String?) -> Bool {
		if let inputValue = value, let mount = Int(inputValue.prefix(2)), let year = Int(inputValue.suffix(2)), mount > 0, mount < 13 {
			return validateCardExpiredDate(year: year, month: mount)
		}
		
		return false
	}
	
	func validateCardCVC(cvc: String?) -> Bool {
		if let value = cvc, value.isEmpty == false {
			let numbers = self.decimals(value: value)
			
			return numbers.count == 3
		}
		
		return false
	}
	
}


public class CardRequisitesBrandInfo: CardRequisites, CardRequisitesBrandInfoProtocol {
	
	private let sizeLogoBrand = CGSize.init(width: 56, height: 36)
	private let sizeLogoPaymentSystem = CGSize.init(width: 21, height: 11)
	
	private var lastSearchNumbers: String?
	
	private func onlyDecimalDigits(value: String) -> String {
		return value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
	}
	
	public func cardBrandInfo(numbers: String?, completion: @escaping (_ number: String?, _ iconImage: UIImage?, _ iconSize: CGSize) -> Void) {
				
		let showPaymentSystemLogo: (() -> Void) = {
			self.lastSearchNumbers = nil
			let icon = self.cardPaymentSystem(pstype: self.paymentSystemType(number: numbers))
			completion(numbers, icon.img, icon.size)
		}
		
		showPaymentSystemLogo()
	}
	
	private func cardPaymentSystem(pstype: CardType) -> (img: UIImage?, size: CGSize) {
		var result: UIImage?
		var size: CGSize = .zero
		switch pstype {
		case .unrecognized:
			break
		case .mastercard:
			result = UIImage.init(named: "mc_logo", in: Bundle(for: type(of: self)), compatibleWith: nil)
			size = sizeLogoPaymentSystem
		case .visa:
			result = UIImage.init(named: "visa_logo", in: Bundle(for: type(of: self)), compatibleWith: nil)
			size = sizeLogoPaymentSystem
		case .mir:
			result = UIImage.init(named: "mir_logo", in: Bundle(for: type(of: self)), compatibleWith: nil)
			size = sizeLogoPaymentSystem
		case .maestro:
			result = UIImage.init(named: "maestro_logo", in: Bundle(for: type(of: self)), compatibleWith: nil)
			size = sizeLogoPaymentSystem
		}
		
		return (img: result, size: size)
	}
	
}
