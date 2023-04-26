//
//  PaymentCallbackURL.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 26.04.2023.
//

import Foundation

/// Ссылки для возврата на страницы успешной или неуспешной оплаты, используемые по завершении процесса оплаты во внешнем приложении
///
/// Используется только для оплаты через `Tinkoff Pay`
public struct PaymentCallbackURL: Equatable {
    /// Ссылка на страницу успешной оплаты
    public let successURL: String
    /// Ссылка на страницу неуспешной оплаты
    public let failureURL: String

    /// Ссылки для возврата на страницы успешной или неуспешной оплаты, используемые по завершении процесса оплаты во внешнем приложении
    /// - Parameters:
    ///   - successURL: Ссылка на страницу успешной оплаты
    ///   - failureURL: Ссылка на страницу неуспешной оплаты
    public init(successURL: String, failureURL: String) {
        self.successURL = successURL
        self.failureURL = failureURL
    }
}
