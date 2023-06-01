//
//  CardRequisitesMasksResolverMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 31.05.2023.
//

@testable import TinkoffASDKUI

final class CardRequisitesMasksResolverMock: ICardRequisitesMasksResolver {
    var validThruMask: String {
        get { return underlyingValidThruMask }
        set(value) { underlyingValidThruMask = value }
    }

    var underlyingValidThruMask: String!

    var cvcMask: String {
        get { return underlyingCvcMask }
        set(value) { underlyingCvcMask = value }
    }

    var underlyingCvcMask: String!

    // MARK: - panMask

    var panMaskCallsCount = 0
    var panMaskReceivedArguments: String?
    var panMaskReceivedInvocations: [String?] = []
    var panMaskReturnValue: String = ""

    func panMask(for pan: String?) -> String {
        panMaskCallsCount += 1
        let arguments = pan
        panMaskReceivedArguments = arguments
        panMaskReceivedInvocations.append(arguments)
        return panMaskReturnValue
    }
}

// MARK: - Public methods

extension CardRequisitesMasksResolverMock {
    func fullReset() {
        underlyingValidThruMask = nil
        underlyingCvcMask = nil

        panMaskCallsCount = 0
        panMaskReceivedArguments = nil
        panMaskReceivedInvocations = []
        panMaskReturnValue = ""
    }
}
