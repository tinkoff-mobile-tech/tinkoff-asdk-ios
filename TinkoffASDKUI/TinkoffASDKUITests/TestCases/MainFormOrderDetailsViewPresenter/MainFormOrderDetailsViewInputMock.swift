//
//  MainFormOrderDetailsViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 09.06.2023.
//

@testable import TinkoffASDKUI

final class MainFormOrderDetailsViewInputMock: IMainFormOrderDetailsViewInput {

    // MARK: - setAmountDescription

    var setAmountDescriptionCallsCount = 0
    var setAmountDescriptionReceivedArguments: String?
    var setAmountDescriptionReceivedInvocations: [String] = []

    func set(amountDescription: String) {
        setAmountDescriptionCallsCount += 1
        let arguments = amountDescription
        setAmountDescriptionReceivedArguments = arguments
        setAmountDescriptionReceivedInvocations.append(arguments)
    }

    // MARK: - setAmount

    var setAmountCallsCount = 0
    var setAmountReceivedArguments: String?
    var setAmountReceivedInvocations: [String] = []

    func set(amount: String) {
        setAmountCallsCount += 1
        let arguments = amount
        setAmountReceivedArguments = arguments
        setAmountReceivedInvocations.append(arguments)
    }

    // MARK: - setOrderDescription

    var setOrderDescriptionCallsCount = 0
    var setOrderDescriptionReceivedArguments: String?
    var setOrderDescriptionReceivedInvocations: [String?] = []

    func set(orderDescription: String?) {
        setOrderDescriptionCallsCount += 1
        let arguments = orderDescription
        setOrderDescriptionReceivedArguments = arguments
        setOrderDescriptionReceivedInvocations.append(arguments)
    }
}

// MARK: - Public methods

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
