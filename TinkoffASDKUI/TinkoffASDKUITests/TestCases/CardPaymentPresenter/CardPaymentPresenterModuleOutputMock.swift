//
//  CardPaymentPresenterModuleOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 19.05.2023.
//

@testable import TinkoffASDKUI

final class CardPaymentPresenterModuleOutputMock: ICardPaymentPresenterModuleOutput {

    // MARK: - cardPaymentWillCloseAfterFinishedPayment

    var cardPaymentWillCloseAfterFinishedPaymentCallsCount = 0
    var cardPaymentWillCloseAfterFinishedPaymentReceivedArguments: FullPaymentData?
    var cardPaymentWillCloseAfterFinishedPaymentReceivedInvocations: [FullPaymentData] = []

    func cardPaymentWillCloseAfterFinishedPayment(with paymentData: FullPaymentData) {
        cardPaymentWillCloseAfterFinishedPaymentCallsCount += 1
        let arguments = paymentData
        cardPaymentWillCloseAfterFinishedPaymentReceivedArguments = arguments
        cardPaymentWillCloseAfterFinishedPaymentReceivedInvocations.append(arguments)
    }

    // MARK: - cardPaymentWillCloseAfterCancelledPayment

    typealias CardPaymentWillCloseAfterCancelledPaymentArguments = (paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?)

    var cardPaymentWillCloseAfterCancelledPaymentCallsCount = 0
    var cardPaymentWillCloseAfterCancelledPaymentReceivedArguments: CardPaymentWillCloseAfterCancelledPaymentArguments?
    var cardPaymentWillCloseAfterCancelledPaymentReceivedInvocations: [CardPaymentWillCloseAfterCancelledPaymentArguments] = []

    func cardPaymentWillCloseAfterCancelledPayment(with paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?) {
        cardPaymentWillCloseAfterCancelledPaymentCallsCount += 1
        let arguments = (paymentProcess, cardId, rebillId)
        cardPaymentWillCloseAfterCancelledPaymentReceivedArguments = arguments
        cardPaymentWillCloseAfterCancelledPaymentReceivedInvocations.append(arguments)
    }

    // MARK: - cardPaymentWillCloseAfterFailedPayment

    typealias CardPaymentWillCloseAfterFailedPaymentArguments = (error: Error, cardId: String?, rebillId: String?)

    var cardPaymentWillCloseAfterFailedPaymentCallsCount = 0
    var cardPaymentWillCloseAfterFailedPaymentReceivedArguments: CardPaymentWillCloseAfterFailedPaymentArguments?
    var cardPaymentWillCloseAfterFailedPaymentReceivedInvocations: [CardPaymentWillCloseAfterFailedPaymentArguments] = []

    func cardPaymentWillCloseAfterFailedPayment(with error: Error, cardId: String?, rebillId: String?) {
        cardPaymentWillCloseAfterFailedPaymentCallsCount += 1
        let arguments = (error, cardId, rebillId)
        cardPaymentWillCloseAfterFailedPaymentReceivedArguments = arguments
        cardPaymentWillCloseAfterFailedPaymentReceivedInvocations.append(arguments)
    }

    // MARK: - cardPaymentDidCloseAfterFinishedPayment

    var cardPaymentDidCloseAfterFinishedPaymentCallsCount = 0
    var cardPaymentDidCloseAfterFinishedPaymentReceivedArguments: FullPaymentData?
    var cardPaymentDidCloseAfterFinishedPaymentReceivedInvocations: [FullPaymentData] = []

    func cardPaymentDidCloseAfterFinishedPayment(with paymentData: FullPaymentData) {
        cardPaymentDidCloseAfterFinishedPaymentCallsCount += 1
        let arguments = paymentData
        cardPaymentDidCloseAfterFinishedPaymentReceivedArguments = arguments
        cardPaymentDidCloseAfterFinishedPaymentReceivedInvocations.append(arguments)
    }

    // MARK: - cardPaymentDidCloseAfterCancelledPayment

    typealias CardPaymentDidCloseAfterCancelledPaymentArguments = (paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?)

    var cardPaymentDidCloseAfterCancelledPaymentCallsCount = 0
    var cardPaymentDidCloseAfterCancelledPaymentReceivedArguments: CardPaymentDidCloseAfterCancelledPaymentArguments?
    var cardPaymentDidCloseAfterCancelledPaymentReceivedInvocations: [CardPaymentDidCloseAfterCancelledPaymentArguments] = []

    func cardPaymentDidCloseAfterCancelledPayment(with paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?) {
        cardPaymentDidCloseAfterCancelledPaymentCallsCount += 1
        let arguments = (paymentProcess, cardId, rebillId)
        cardPaymentDidCloseAfterCancelledPaymentReceivedArguments = arguments
        cardPaymentDidCloseAfterCancelledPaymentReceivedInvocations.append(arguments)
    }

    // MARK: - cardPaymentDidCloseAfterFailedPayment

    typealias CardPaymentDidCloseAfterFailedPaymentArguments = (error: Error, cardId: String?, rebillId: String?)

    var cardPaymentDidCloseAfterFailedPaymentCallsCount = 0
    var cardPaymentDidCloseAfterFailedPaymentReceivedArguments: CardPaymentDidCloseAfterFailedPaymentArguments?
    var cardPaymentDidCloseAfterFailedPaymentReceivedInvocations: [CardPaymentDidCloseAfterFailedPaymentArguments] = []

    func cardPaymentDidCloseAfterFailedPayment(with error: Error, cardId: String?, rebillId: String?) {
        cardPaymentDidCloseAfterFailedPaymentCallsCount += 1
        let arguments = (error, cardId, rebillId)
        cardPaymentDidCloseAfterFailedPaymentReceivedArguments = arguments
        cardPaymentDidCloseAfterFailedPaymentReceivedInvocations.append(arguments)
    }
}
