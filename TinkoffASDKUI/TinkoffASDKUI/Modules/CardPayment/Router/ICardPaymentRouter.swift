//
//  ICardPaymentRouter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

protocol ICardPaymentRouter {
    func closeScreen(completion: VoidBlock?)
}

extension ICardPaymentRouter {
    /// Для удобства / красоты
    func closeScreen() {
        closeScreen(completion: nil)
    }
}
