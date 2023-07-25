//
//  CardDataFormatterMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 21.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class CardDataFormatterMock: ICardDataFormatter {

    // MARK: - formatCardDataCardNumberExpDate

    typealias FormatCardDataCardNumberExpDateArguments = (cardNumber: String, expDate: String, cvv: String)

    var formatCardDataCardNumberExpDateCallsCount = 0
    var formatCardDataCardNumberExpDateReceivedArguments: FormatCardDataCardNumberExpDateArguments?
    var formatCardDataCardNumberExpDateReceivedInvocations: [FormatCardDataCardNumberExpDateArguments?] = []
    var formatCardDataCardNumberExpDateReturnValue: String!

    func formatCardData(cardNumber: String, expDate: String, cvv: String) -> String {
        formatCardDataCardNumberExpDateCallsCount += 1
        let arguments = (cardNumber, expDate, cvv)
        formatCardDataCardNumberExpDateReceivedArguments = arguments
        formatCardDataCardNumberExpDateReceivedInvocations.append(arguments)
        return formatCardDataCardNumberExpDateReturnValue
    }

    // MARK: - formatCardDataCardIdCvv

    typealias FormatCardDataCardIdCvvArguments = (cardId: String, cvv: String?)

    var formatCardDataCardIdCvvCallsCount = 0
    var formatCardDataCardIdCvvReceivedArguments: FormatCardDataCardIdCvvArguments?
    var formatCardDataCardIdCvvReceivedInvocations: [FormatCardDataCardIdCvvArguments?] = []
    var formatCardDataCardIdCvvReturnValue: String!

    func formatCardData(cardId: String, cvv: String?) -> String {
        formatCardDataCardIdCvvCallsCount += 1
        let arguments = (cardId, cvv)
        formatCardDataCardIdCvvReceivedArguments = arguments
        formatCardDataCardIdCvvReceivedInvocations.append(arguments)
        return formatCardDataCardIdCvvReturnValue
    }
}

// MARK: - Resets

extension CardDataFormatterMock {
    func fullReset() {
        formatCardDataCardNumberExpDateCallsCount = 0
        formatCardDataCardNumberExpDateReceivedArguments = nil
        formatCardDataCardNumberExpDateReceivedInvocations = []

        formatCardDataCardIdCvvCallsCount = 0
        formatCardDataCardIdCvvReceivedArguments = nil
        formatCardDataCardIdCvvReceivedInvocations = []
    }
}
