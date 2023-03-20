//
//  TinkoffPayMethod.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 06.03.2023.
//

import Foundation

/// Данные для оплаты с помощью `TinkoffPay`
public struct TinkoffPayMethod: Hashable {
    /// Версия `TinkoffPay` доступная на данном терминале.
    /// Используется для получения `URL` в методе `GetTinkoffPayLink`
    public let version: String

    /// Данные для оплаты с помощью `TinkoffPay`
    /// - Parameter version: Версия `TinkoffPay` доступная на данном терминале.
    /// Используется для получения `URL` в методе `GetTinkoffPayLink`
    public init(version: String) {
        self.version = version
    }
}

// MARK: - Decodable

extension TinkoffPayMethod: Decodable {
    private enum CodingKeys: String, CodingKey {
        case version = "Version"
    }
}
