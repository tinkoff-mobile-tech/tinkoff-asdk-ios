//
//  GetAddCardStateData.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 18.02.2023.
//

import Foundation

/// Данные для запроса статуса привязки карты
public struct GetAddCardStateData {
    /// Идентификатор запроса на привязку карты
    public let requestKey: String

    /// Данные для запроса статуса привязки карты
    /// - Parameter requestKey: Идентификатор запроса на привязку карты
    public init(requestKey: String) {
        self.requestKey = requestKey
    }
}

// MARK: - Encodable

extension GetAddCardStateData: Encodable {
    private enum CodingKeys: CodingKey {
        case requestKey

        var stringValue: String {
            switch self {
            case .requestKey: return Constants.Keys.requestKey
            }
        }
    }
}
