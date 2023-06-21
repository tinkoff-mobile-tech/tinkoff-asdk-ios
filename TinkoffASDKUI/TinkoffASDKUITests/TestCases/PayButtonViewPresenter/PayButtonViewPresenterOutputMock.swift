//
//  PayButtonViewPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.05.2023.
//

@testable import TinkoffASDKUI

final class PayButtonViewPresenterOutputMock: IPayButtonViewPresenterOutput {

    // MARK: - payButtonViewTapped

    var payButtonViewTappedCallsCount = 0
    var payButtonViewTappedReceivedArguments: IPayButtonViewPresenterInput?
    var payButtonViewTappedReceivedInvocations: [IPayButtonViewPresenterInput] = []

    func payButtonViewTapped(_ presenter: IPayButtonViewPresenterInput) {
        payButtonViewTappedCallsCount += 1
        let arguments = presenter
        payButtonViewTappedReceivedArguments = arguments
        payButtonViewTappedReceivedInvocations.append(arguments)
    }
}
