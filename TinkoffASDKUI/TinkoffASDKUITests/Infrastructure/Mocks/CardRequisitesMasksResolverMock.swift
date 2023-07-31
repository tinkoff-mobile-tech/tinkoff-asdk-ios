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

    typealias PanMaskArguments = String

    var panMaskCallsCount = 0
    var panMaskReceivedArguments: PanMaskArguments?
    var panMaskReceivedInvocations: [PanMaskArguments?] = []
    var panMaskReturnValue = ""

    func panMask(for pan: String?) -> String {
        panMaskCallsCount += 1
        let arguments = pan
        panMaskReceivedArguments = arguments
        panMaskReceivedInvocations.append(arguments)
        return panMaskReturnValue
    }
}

// MARK: - Resets

extension CardRequisitesMasksResolverMock {
    func fullReset() {
        panMaskCallsCount = 0
        panMaskReceivedArguments = nil
        panMaskReceivedInvocations = []
    }
}
