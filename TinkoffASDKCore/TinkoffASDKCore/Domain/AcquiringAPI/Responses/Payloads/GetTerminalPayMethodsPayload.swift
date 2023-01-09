//
//  GetTerminalPayMethodsPayload.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 29.11.2022.
//

import Foundation

/// Ответ сервера о доступных методах оплаты и настройках терминала
public struct GetTerminalPayMethodsPayload {
    /// Информация о доступных методах оплаты и настройках терминала
    public let terminalInfo: TerminalInfo
}

// MARK: - GetTerminalPayMethodsPayload + Decodable

extension GetTerminalPayMethodsPayload: Decodable {
    private enum CodingKeys: String, CodingKey {
        case terminalInfo = "TerminalInfo"
    }
}
