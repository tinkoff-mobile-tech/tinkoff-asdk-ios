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
