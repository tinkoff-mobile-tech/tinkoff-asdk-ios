//
//  PaymentCard.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

public struct PaymentCard: Codable {
    private enum CodingKeys: CodingKey {
        case pan
        case cardId
        case status
        case parentPaymentId
        case expDate

        var stringValue: String {
            switch self {
            case .pan: return "Pan"
            case .cardId: return Constants.Keys.cardId
            case .status: return Constants.Keys.status
            case .parentPaymentId: return Constants.Keys.rebillId
            case .expDate: return Constants.Keys.cardExpDate
            }
        }
    }

    /// Название карты, по умолчанию выставяется замаскированный номер, например `430000******0777`
    public var pan: String
    public var cardId: String
    public var status: PaymentCardStatus
    /// Идентификатор родительского платежа
    /// Последний платеж с этой карты, который был  зарегистрирован как родительский платеж
    public var parentPaymentId: Int64?
    /// Срок годности карты в формате `MMYY`, например `1212`, для формата даты используем `expDateFormat`
    public var expDate: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pan = try container.decode(String.self, forKey: .pan)
        cardId = try container.decode(String.self, forKey: .cardId)
        let statusRawValue = try container.decode(String.self, forKey: .status)
        status = PaymentCardStatus(rawValue: statusRawValue)

        if let stringValue = try? container.decode(String.self, forKey: .parentPaymentId), let value = Int64(stringValue) {
            parentPaymentId = value
        } else {
            parentPaymentId = try? container.decode(Int64.self, forKey: .parentPaymentId)
        }

        expDate = try? container.decode(String.self, forKey: .expDate)
    }

    public init(pan: String, cardId: String, status: PaymentCardStatus, parentPaymentId: Int64?, expDate: String?) {
        self.pan = pan
        self.cardId = cardId
        self.status = status
        self.parentPaymentId = parentPaymentId
        self.expDate = expDate
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pan, forKey: .pan)
        try container.encode(cardId, forKey: .cardId)
        try container.encode(status.rawValue, forKey: .status)
        if parentPaymentId != nil { try? container.encode(parentPaymentId, forKey: .parentPaymentId) }
        if expDate != nil { try? container.encode(expDate, forKey: .expDate) }
    }
}

public extension PaymentCard {
    func expDateFormat() -> String? {
        if let mm = expDate?.prefix(2), let yy = expDate?.suffix(2) {
            return "\(mm)/\(yy)"
        }

        return expDate
    }
}
