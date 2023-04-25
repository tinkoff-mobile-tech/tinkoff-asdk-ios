//
//  YPPaymentSheetFactoryMock.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI
@testable import TinkoffASDKYandexPay
import YandexPaySDK

final class YPPaymentSheetFactoryMock: IYPPaymentSheetFactory {

    // MARK: - create

    var createCallsCount = 0
    var createReceivedArguments: PaymentFlow?
    var createReceivedInvocations: [PaymentFlow] = []
    var createReturnValue: YPPaymentSheet!

    func create(with paymentFlow: PaymentFlow) -> YPPaymentSheet {
        createCallsCount += 1
        let arguments = paymentFlow
        createReceivedArguments = arguments
        createReceivedInvocations.append(arguments)
        return createReturnValue
    }
}
