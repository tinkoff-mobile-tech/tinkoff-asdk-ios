//
//  IYandexPayPaymentFlowAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

/// Объект, формирующий `IYandexPayPaymentFlow`
public protocol IYandexPayPaymentFlowAssembly {
    /// Формирование `IYandexPayPaymentFlow`
    func yandexPayPaymentFlow() -> IYandexPayPaymentFlow
}
