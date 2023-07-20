//
//  MainFormOrderDetailsViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 09.06.2023.
//

@testable import TinkoffASDKUI

final class MainFormOrderDetailsViewInputMock: IMainFormOrderDetailsViewInput {

    // MARK: - setAmountDescription

    typealias SetAmountDescriptionArguments = String

    var setAmountDescriptionCallsCount = 0
    var setAmountDescriptionReceivedArguments: SetAmountDescriptionArguments?
    var setAmountDescriptionReceivedInvocations: [SetAmountDescriptionArguments?] = []

    func set(amountDescription: String) {
        setAmountDescriptionCallsCount += 1
        let arguments = amountDescription
        setAmountDescriptionReceivedArguments = arguments
        setAmountDescriptionReceivedInvocations.append(arguments)
    }

    // MARK: - setAmount

    typealias SetAmountArguments = String

    var setAmountCallsCount = 0
    var setAmountReceivedArguments: SetAmountArguments?
    var setAmountReceivedInvocations: [SetAmountArguments?] = []

    func set(amount: String) {
        setAmountCallsCount += 1
        let arguments = amount
        setAmountReceivedArguments = arguments
        setAmountReceivedInvocations.append(arguments)
    }

    // MARK: - setOrderDescription

    typealias SetOrderDescriptionArguments = String

    var setOrderDescriptionCallsCount = 0
    var setOrderDescriptionReceivedArguments: SetOrderDescriptionArguments?
    var setOrderDescriptionReceivedInvocations: [SetOrderDescriptionArguments?] = []

    func set(orderDescription: String?) {
        setOrderDescriptionCallsCount += 1
        let arguments = orderDescription
        setOrderDescriptionReceivedArguments = arguments
        setOrderDescriptionReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension MainFormOrderDetailsViewInputMock {
    func fullReset() {
        setAmountDescriptionCallsCount = 0
        setAmountDescriptionReceivedArguments = nil
        setAmountDescriptionReceivedInvocations = []

        setAmountCallsCount = 0
        setAmountReceivedArguments = nil
        setAmountReceivedInvocations = []

        setOrderDescriptionCallsCount = 0
        setOrderDescriptionReceivedArguments = nil
        setOrderDescriptionReceivedInvocations = []
    }
}
