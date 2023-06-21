//
//  MoneyFormatterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.05.2023.
//

@testable import TinkoffASDKUI

final class MoneyFormatterMock: IMoneyFormatter {

    // MARK: - formatAmount

    var formatAmountCallsCount = 0
    var formatAmountReceivedArguments: Int?
    var formatAmountReceivedInvocations: [Int] = []
    var formatAmountReturnValue: String = ""

    func formatAmount(_ amount: Int) -> String {
        formatAmountCallsCount += 1
        let arguments = amount
        formatAmountReceivedArguments = arguments
        formatAmountReceivedInvocations.append(arguments)
        return formatAmountReturnValue
    }
}

// MARK: - Public methods

extension MoneyFormatterMock {
    func fullReset() {
        formatAmountCallsCount = 0
        formatAmountReceivedArguments = nil
        formatAmountReceivedInvocations = []
        formatAmountReturnValue = ""
    }
}
