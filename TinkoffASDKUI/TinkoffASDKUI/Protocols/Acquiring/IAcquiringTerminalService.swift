//
//  IAcquiringTerminalService.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation
import TinkoffASDKCore

protocol IAcquiringTerminalService {
    /// Получить информацию о доступных методах оплаты и настройках терминала
    ///
    /// - Parameter completion: Callback с результатом запроса. `GetTerminalPayMethodsPayload` - при успехе, `Error` - при ошибке
    /// - Returns: `Cancellable`
    @discardableResult
    func getTerminalPayMethods(
        completion: @escaping (Result<GetTerminalPayMethodsPayload, Error>) -> Void
    ) -> Cancellable
}
