//
//
//  CardRequisitesValidator.swift
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

protocol ICardRequisitesValidator {
    func validate(inputPAN: String?) -> Bool
    func validate(validThruYear: Int, month: Int) -> Bool
    func validate(inputCVC: String?) -> Bool
}

final class CardRequisitesValidator: ICardRequisitesValidator {
    // MARK: Options

    struct Options: OptionSet {
        /// Отключение валидации срока действия карты
        static let disableExpiryDateValidation = Options(rawValue: 1 << 0)

        let rawValue: Int
    }

    // MARK: Dependencies

    private let paymentSystemResolver: IPaymentSystemResolver
    private let options: Options

    // MARK: Init

    init(
        paymentSystemResolver: IPaymentSystemResolver = PaymentSystemResolver(),
        options: Options = [.disableExpiryDateValidation]
    ) {
        self.paymentSystemResolver = paymentSystemResolver
        self.options = options
    }

    // MARK: PAN Validation

    func validate(inputPAN: String?) -> Bool {
        guard let inputPAN = inputPAN else {
            return false
        }

        let paymentSystem = paymentSystemResolver.resolve(by: inputPAN)

        return PANLengthValidator.validate(paymentSystem: paymentSystem, length: inputPAN.count)
            && PANLuhnValidator.validate(inputPAN)
    }

    // MARK: ValidThru Validation

    func validate(validThruYear year: Int, month: Int) -> Bool {
        guard (0 ... 99).contains(year),
              (0 ... 12).contains(month)
        else { return false }

        guard !options.contains(.disableExpiryDateValidation) else { return true }

        let currentDate = Date()
        let calendar = Calendar.current

        let yearNow = calendar.component(.year, from: currentDate)
        let monthNow = calendar.component(.month, from: currentDate)

        return (100 * (2000 + year) + month >= 100 * yearNow + monthNow)
    }

    // MARK: CVC Validation

    func validate(inputCVC: String?) -> Bool {
        inputCVC?.decimalDigits.count == 3
    }
}

// MARK: - ICardRequisitesValidator + Input Helpers

extension ICardRequisitesValidator {
    func validate(inputValidThru: String?) -> Bool {
        guard let inputValidThru = inputValidThru,
              let month = Int(inputValidThru.prefix(2)),
              let year = Int(inputValidThru.suffix(2))
        else {
            return false
        }

        return validate(validThruYear: year, month: month)
    }
}

// MARK: - String + Helpers

private extension String {
    var decimalDigits: String {
        components(separatedBy: .decimalDigits.inverted).joined()
    }
}

// MARK: - PANLengthValidator

private enum PANLengthValidator {
    /// Валидация номера карты с учетом платежной системы и возможной длины
    static func validate(paymentSystem: PaymentSystemDecision, length: Int) -> Bool {
        switch paymentSystem {
        case .resolved(.visa), .resolved(.masterCard):
            return length == 16
        case .resolved(.mir), .resolved(.unionPay):
            return (16 ... 19).contains(length)
        case .resolved(.maestro):
            return (13 ... 19).contains(length)
        case .ambiguous, .unrecognized:
            return (13 ... 28).contains(length)
        }
    }
}

// MARK: - PANLuhnValidator

private enum PANLuhnValidator {
    /// Валидация номера карты с помощью алгоритма вычисления контрольной цифры
    /// номера в соответствии со стандартом `ISO/IEC 7812`
    ///
    /// [Реализация алгортима Луна с GitHub](https://gist.github.com/J-L/e2294d19677bbb34c6e1)
    static func validate(_ cardNumber: String) -> Bool {
        var luhnSum = 0
        var digitCount = 0

        for c in cardNumber.reversed() {
            let thisDigit = Int(String(c as Character)) ?? 0
            digitCount += 1
            if digitCount % 2 == 0 {
                if thisDigit * 2 > 9 {
                    luhnSum += thisDigit * 2 - 9
                } else {
                    luhnSum += thisDigit * 2
                }
            } else {
                luhnSum += thisDigit
            }
        }
        if luhnSum % 10 == 0 {
            return true
        }
        return false
    }
}
