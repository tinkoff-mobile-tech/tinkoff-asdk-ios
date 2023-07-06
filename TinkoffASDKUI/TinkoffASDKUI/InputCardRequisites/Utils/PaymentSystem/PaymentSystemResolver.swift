//
//
//  PaymentSystemResolver.swift
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

enum PaymentSystemDecision: Equatable {
    case resolved(PaymentSystem)
    case ambiguous
    case unrecognized

    func getPaymentSystem() -> PaymentSystem? {
        switch self {
        case let .resolved(paymentSystem):
            return paymentSystem
        default:
            return nil
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (resolved(lPaymentSystem), .resolved(rPaymentSystem)):
            return lPaymentSystem == rPaymentSystem
        case (.ambiguous, .ambiguous), (.unrecognized, .unrecognized):
            return true
        default:
            return false
        }
    }
}

protocol IPaymentSystemResolver {
    func resolve(by inputPAN: String?) -> PaymentSystemDecision
}

final class PaymentSystemResolver: IPaymentSystemResolver {

    // MARK: Payment System's Regex Map

    private let paymentSystemsRegexes: [PaymentSystem: NSRegularExpression] = PaymentSystem.allCases
        .reduce(into: [PaymentSystem: NSRegularExpression]()) { partialResult, paymentSystem in
            if let regex = paymentSystem.regexPattern.regex {
                partialResult[paymentSystem] = regex
            }
        }

    // MARK: IPaymentSystemResolver

    func resolve(by inputPAN: String?) -> PaymentSystemDecision {
        guard let inputPAN = inputPAN else { return .unrecognized }

        // Для проверки на соответствие регулярному выражению достаточно
        // использовать только BIN (первые 6 цифр номера карты)
        let inputBIN = String(inputPAN.prefix(Constants.binLength))

        // Для всех карт, начинающихся с цифры 6
        // Валидируем платежную систему со второго символа
        if inputPAN.starts(with: "6"), inputPAN.count < 2 {
            return .ambiguous
        }

        let matchedPaymentSystems = paymentSystemsRegexes
            .filter { _, regex in inputBIN.matches(with: regex) }
            .map(\.key)

        switch matchedPaymentSystems.first {
        case let .some(paymentSystem) where matchedPaymentSystems.count == 1:
            return .resolved(paymentSystem)
        case .some, .none:
            return .unrecognized
        }
    }
}

// MARK: - String + Helpers

private extension String {
    func matches(with regex: NSRegularExpression) -> Bool {
        let range = NSRange(startIndex ..< endIndex, in: self)
        return regex.firstMatch(in: self, range: range) != nil
    }
}

extension PaymentSystemResolver {

    // MARK: Constants

    enum Constants {
        static let binLength = 6
    }
}
