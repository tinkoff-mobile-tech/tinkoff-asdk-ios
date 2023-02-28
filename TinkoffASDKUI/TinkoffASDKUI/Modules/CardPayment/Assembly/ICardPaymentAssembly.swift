//
//  ICardPaymentAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import TinkoffASDKCore
import UIKit

protocol ICardPaymentAssembly {
    /// Собирает модуль, с возможностью оплаты по любой доступной карте, а так же по новой карте
    /// - Parameters:
    ///   - activeCards: Массив с полученными картами на предыдущем этапе.
    ///   При `nil`  модуль самостоятельно загрузит список карт, если в `PaymentFlow` содержится `customerKey`
    func anyCardPayment(
        activeCards: [PaymentCard]?,
        paymentFlow: PaymentFlow,
        amount: Int64,
        output: ICardPaymentPresenterModuleOutput?
    ) -> UIViewController
}

extension ICardPaymentAssembly {
    /// Собирает модуль, с возможностью оплаты по новой карте.
    /// Список карт в этом модуле отсутствует, и не может быть загружен
    func newCardPayment(
        paymentFlow: PaymentFlow,
        amount: Int64,
        output: ICardPaymentPresenterModuleOutput?
    ) -> UIViewController {
        anyCardPayment(
            activeCards: [],
            paymentFlow: paymentFlow,
            amount: amount,
            output: output
        )
    }
}
