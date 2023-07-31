//
//  MoneyFormatterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.05.2023.
//

@testable import TinkoffASDKUI

final class MoneyFormatterMock: IMoneyFormatter {

    // MARK: - formatAmount

    typealias FormatAmountArguments = Int

    var formatAmountCallsCount = 0
    var formatAmountReceivedArguments: FormatAmountArguments?
    var formatAmountReceivedInvocations: [FormatAmountArguments?] = []
    var formatAmountReturnValue = ""

    func formatAmount(_ amount: Int) -> String {
        formatAmountCallsCount += 1
        let arguments = amount
        formatAmountReceivedArguments = arguments
        formatAmountReceivedInvocations.append(arguments)
        return formatAmountReturnValue
    }
}

// MARK: - Resets

extension MoneyFormatterMock {
    func fullReset() {
        formatAmountCallsCount = 0
        formatAmountReceivedArguments = nil
        formatAmountReceivedInvocations = []
    }
}
