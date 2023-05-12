//
//  ICardPaymentPresenterModuleOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 08.02.2023.
//

protocol ICardPaymentPresenterModuleOutput: AnyObject {
    func cardPaymentWillCloseAfterFinishedPayment(with paymentData: FullPaymentData)
    func cardPaymentWillCloseAfterCancelledPayment(with paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?)
    func cardPaymentWillCloseAfterFailedPayment(with error: Error, cardId: String?, rebillId: String?)

    func cardPaymentDidCloseAfterFinishedPayment(with paymentData: FullPaymentData)
    func cardPaymentDidCloseAfterCancelledPayment(with paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?)
    func cardPaymentDidCloseAfterFailedPayment(with error: Error, cardId: String?, rebillId: String?)
}

extension ICardPaymentPresenterModuleOutput {
    func cardPaymentWillCloseAfterFinishedPayment(with paymentData: FullPaymentData) {}
    func cardPaymentWillCloseAfterCancelledPayment(with paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?) {}
    func cardPaymentWillCloseAfterFailedPayment(with error: Error, cardId: String?, rebillId: String?) {}

    func cardPaymentDidCloseAfterFinishedPayment(with paymentData: FullPaymentData) {}
    func cardPaymentDidCloseAfterCancelledPayment(with paymentProcess: IPaymentProcess, cardId: String?, rebillId: String?) {}
    func cardPaymentDidCloseAfterFailedPayment(with error: Error, cardId: String?, rebillId: String?) {}
}
