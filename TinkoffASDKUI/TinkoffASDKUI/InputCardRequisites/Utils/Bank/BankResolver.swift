//
//  BankResolver.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 16.11.2022.
//

import Foundation

enum BankResult: Equatable {

    enum InputValidationError: Error, Equatable {
        case noValue
        case notEnoughData
    }

    case parsed(bank: Bank)
    case incorrectInput(error: InputValidationError)

    func getBank() -> Bank? {
        if case let .parsed(bank) = self {
            return bank
        } else {
            return nil
        }
    }
}

// MARK: - IBankResolver

protocol IBankResolver {

    func resolve(cardNumber: String?) -> BankResult
}

// MARK: - BankResolver

final class BankResolver: IBankResolver {

    func resolve(cardNumber: String?) -> BankResult {
        guard let cardNumber = cardNumber else { return .incorrectInput(error: .noValue) }
        let validationError = validateInput(cardNumber)

        if let validationError = validationError {
            return .incorrectInput(error: validationError)
        }

        // valid pan

        let bin = String(cardNumber.prefix(Constants.cardNumberBinDigitsCount))

        var tempResult: Bank?

        for bankType in Bank.allCases {
            if bankType.bins.contains(bin) {
                tempResult = bankType
                break
            }
        }

        let bank = tempResult ?? .other

        return .parsed(bank: bank)
    }

    // MARK: - Private

    private func validateInput(_ input: String) -> BankResult.InputValidationError? {
        guard !input.isEmpty else { return .noValue }
        guard input.count >= Constants.cardNumberBinDigitsCount else { return .notEnoughData }
        return nil
    }
}

// MARK: - BankResolver + Constants

private extension BankResolver {

    enum Constants {
        static let cardNumberBinDigitsCount = 6
    }
}
