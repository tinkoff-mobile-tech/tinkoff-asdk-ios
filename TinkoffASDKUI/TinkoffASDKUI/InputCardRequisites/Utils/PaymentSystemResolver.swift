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

enum PaymentSystemDecision {
    enum PaymentSystem: CaseIterable {
        case visa
        case masterCard
        case maestro
        case mir
    }

    case resolved(PaymentSystem)
    case ambiguous
    case unrecognized
}

protocol IPaymentSystemResolver {
    func resolve(by inputPAN: String?) -> PaymentSystemDecision
}

final class PaymentSystemResolver: IPaymentSystemResolver {
    // MARK: Payment System's Patterns

    enum Pattern: String, CaseIterable {
        case visa = "^(4[0-9]*)$"
        case masterCard = "^(5(?!05827|61468)[0-9]*)$"
        case maestro = "^(6(?!2|76347|76454|76531|71182|76884|76907|77319|77384)[0-9]*)$"
        case mir = """
        ^((220[0-4]|356|505827|561468|623446|629129|629157|629244|676347\
        |676454|676531|671182|676884|676907|677319|677384|8600|9051|9112\
        (?!00|50|39|99)|9417(?!00|99)|9762|9777|9990(?!01))[0-9]*)$
        """

        var regex: NSRegularExpression? {
            try? NSRegularExpression(pattern: rawValue)
        }
    }

    // MARK: Constants

    private enum Constants {
        static let binLength = 6
    }

    // MARK: Payment System's Regex Map

    private let paymentSystemsRegexes: [PaymentSystemDecision.PaymentSystem: NSRegularExpression] = [
        .visa: Pattern.visa,
        .masterCard: Pattern.masterCard,
        .maestro: Pattern.maestro,
        .mir: Pattern.mir,
    ].compactMapValues(\.regex)

    // MARK: IPaymentSystemResolver

    func resolve(by inputPAN: String?) -> PaymentSystemDecision {
        guard let inputPAN = inputPAN else { return .unrecognized }

        // Для проверки на соответствие регулярному выражению достаточно
        // использовать только BIN (первые 6 цифр номера карты)
        let inputBIN = String(inputPAN.prefix(Constants.binLength))

        let matchedPaymentSystems = paymentSystemsRegexes
            .filter { _, regex in inputBIN.matches(with: regex) }
            .map(\.key)

        switch matchedPaymentSystems.first {
        case let .some(paymentSystem) where matchedPaymentSystems.count == 1:
            return .resolved(paymentSystem)
        case .some:
            return .ambiguous
        case .none:
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
