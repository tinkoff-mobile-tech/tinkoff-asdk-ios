//
//  IAcquiringTinkoffPayService.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 06.03.2023.
//

import Foundation
import TinkoffASDKCore

protocol IAcquiringTinkoffPayService {
    /// Получить ссылку для оплаты с помощью `TinkoffPay`
    ///
    /// - Parameters:
    ///   - data: `GetTinkoffLinkData` - Данные для запроса на получение ссылки на оплату с помощью TinkoffPay
    ///   - completion: Callback с результатом запроса. `GetTinkoffLinkPayload` - при успехе, `Error` - при ошибке
    /// - Returns: `Cancellable`
    @discardableResult
    func getTinkoffPayLink(
        data: GetTinkoffLinkData,
        completion: @escaping (Result<GetTinkoffLinkPayload, Error>) -> Void
    ) -> Cancellable
}
