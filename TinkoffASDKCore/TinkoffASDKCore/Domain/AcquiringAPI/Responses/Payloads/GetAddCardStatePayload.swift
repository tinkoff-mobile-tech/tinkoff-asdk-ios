//
//  GetAddCardStatePayload.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 18.02.2023.
//

import Foundation

///  Статус привязки карты
public struct GetAddCardStatePayload {
    /// Идентификатор запроса на привязку карты
    public let requestKey: String
    /// Статус привязки карты
    public let status: AcquiringStatus
    /// Идентификатор карты в системе Банка
    public let cardId: String?
    /// Идентификатор рекуррентного платежа
    public let rebillId: String?

    /// Статус привязки карты
    /// - Parameters:
    ///   - requestKey: Идентификатор запроса на привязку карты
    ///   - status: Статус привязки карты
    ///   - cardId: Идентификатор карты в системе Банка
    ///   - rebillId: Идентификатор рекуррентного платежа
    public init(
        requestKey: String,
        status: AcquiringStatus,
        cardId: String?,
        rebillId: String?
    ) {
        self.requestKey = requestKey
        self.status = status
        self.cardId = cardId
        self.rebillId = rebillId
    }
}

// MARK: - Decodable

extension GetAddCardStatePayload: Decodable {
    private enum CodingKeys: CodingKey {
        case requestKey
        case status
        case cardId
        case rebillId

        var stringValue: String {
            switch self {
            case .requestKey: return Constants.Keys.requestKey
            case .status: return Constants.Keys.status
            case .cardId: return Constants.Keys.cardId
            case .rebillId: return Constants.Keys.rebillId
            }
        }
    }
}
