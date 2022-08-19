//
//
//  CardRequisitesMasksResolver.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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


import Foundation

protocol ICardRequisitesMasksResolver {
    var validThruMask: String { get }
    var cvcMask: String { get }
    func panMask(for pan: String?) -> String
}

final class CardRequisitesMasksResolver {
    // MARK: Mask

    private enum Mask {
        static let digits13 = "[0000] [0000] [00000]"
        static let digits15 = "[0000] [000000] [0000]"
        static let digits16 = "[0000] [0000] [0000] [0000]"
        static let digits19 = "[000000] [0000000000000]"
        static let validThru = "[00]/[00]"
        static let cvc = "[000]"

        static func continuousDigits(length: Int) -> String {
            guard length > .zero else { return "" }
            return "[\(String(repeating: "0", count: length))]"
        }
    }

    // MARK: Length

    private enum Length {
        static let mirMax = 19
        static let maestroMax = 19
        static let defaultMax = 28

        static func mirSuffixLength(base: Int) -> Int {
            mirMax - base
        }

        static func maestroSuffixLength(base: Int) -> Int {
            maestroMax - base
        }
    }

    // MARK: Dependencies

    private let paymentSystemResolver: IPaymentSystemResolver

    // MARK: Init

    init(paymentSystemResolver: IPaymentSystemResolver) {
        self.paymentSystemResolver = paymentSystemResolver
    }
}

// MARK: - ICardRequisitesMasksResolver

extension CardRequisitesMasksResolver: ICardRequisitesMasksResolver {
    var validThruMask: String {
        Mask.validThru
    }

    var cvcMask: String {
        Mask.cvc
    }

    func panMask(for pan: String?) -> String {
        let length = pan?.count ?? .zero

        switch paymentSystemResolver.resolve(by: pan) {
        case .resolved(.visa), .resolved(.masterCard):
            return Mask.digits16
        case .resolved(.mir):
            switch length {
            case ...16:
                return Mask.digits16.appending(Mask.continuousDigits(length: Length.mirSuffixLength(base: length)))
            case 17, 18:
                return Mask.continuousDigits(length: Length.mirMax)
            default:
                return Mask.digits19
            }
        case .resolved(.maestro):
            switch length {
            case 13:
                return Mask.digits13.appending(Mask.continuousDigits(length: Length.maestroSuffixLength(base: length)))
            case 15:
                return Mask.digits15.appending(Mask.continuousDigits(length: Length.maestroSuffixLength(base: length)))
            case 16:
                return Mask.digits16.appending(Mask.continuousDigits(length: Length.maestroSuffixLength(base: length)))
            case 19:
                return Mask.digits19
            default:
                return Mask.continuousDigits(length: Length.maestroMax)
            }
        case .ambiguous, .unrecognized:
            return Mask.continuousDigits(length: Length.defaultMax)
        }
    }
}
