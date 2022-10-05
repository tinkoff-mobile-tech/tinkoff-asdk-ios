//
//  InputCardRequisitesProtocolsDeprecated.swift
//  TinkoffASDKUI
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

// TODO: MIC-6013 Remove redundant entities
@available(*, deprecated, message: "The protocol is deprecated and will be removed in the next releases")
public protocol CardRequisitesBrandInfoProtocol {
    func cardBrandInfo(numbers: String?, completion: @escaping (_ requisites: String?, _ icon: UIImage?, _ iconSize: CGSize) -> Void)
}

// TODO: MIC-6013 Remove redundant entities
@available(*, deprecated, message: "The class is deprecated and will be removed in the next releases")
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
                        let regexp = try NSRegularExpression(pattern: "220[0-4]", options: .caseInsensitive)
                        let matches = regexp.matches(in: String(prefix4), options: [], range: NSRange(location: 0, length: prefix4.count))
                        if matches.count == 1 {
                            result = .mir
                        }
                    } catch {}
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

// TODO: MIC-6013 Remove redundant entities
@available(*, deprecated, message: "The class is deprecated and will be removed in the next releases")
public class CardRequisitesBrandInfo: CardRequisites, CardRequisitesBrandInfoProtocol {
    private let sizeLogoBrand = CGSize(width: 56, height: 36)
    private let sizeLogoPaymentSystem = CGSize(width: 21, height: 11)

    private var lastSearchNumbers: String?

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
            result = Asset.CardRequisites.mcLogo.image
            size = sizeLogoPaymentSystem
        case .visa:
            result = Asset.CardRequisites.visaLogo.image
            size = sizeLogoPaymentSystem
        case .mir:
            result = Asset.CardRequisites.mirLogo.image
            size = sizeLogoPaymentSystem
        case .maestro:
            result = Asset.CardRequisites.maestroLogo.image
            size = sizeLogoPaymentSystem
        }

        return (img: result, size: size)
    }
}
