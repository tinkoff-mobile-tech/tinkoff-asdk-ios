//
//  PaymentSourceData.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Источник оплаты
public enum PaymentSourceData: Codable {
    // MARK: CodingKeys

    private enum CodingKeys: CodingKey {
        case cardNumber
        case cardExpDate
        case cardCVV
        case savedCardId
        case paymentData

        var stringValue: String {
            switch self {
            case .cardNumber: return APIConstants.Keys.cardNumber
            case .cardExpDate: return APIConstants.Keys.cardExpDate
            case .cardCVV: return APIConstants.Keys.cardCVV
            case .savedCardId: return APIConstants.Keys.cardId
            case .paymentData: return APIConstants.Keys.paymentData
            }
        }
    }

    // MARK: Cases

    /// при оплате по реквизитам  карты
    ///
    /// - Parameters:
    ///   - number: номер карты в виде строки
    ///   - expDate: expiration date в виде строки `MMYY`
    ///   - cvv: код `CVV` в виде строки.
    case cardNumber(number: String, expDate: String, cvv: String)

    /// при оплате с ранее сохраненной карты
    ///
    /// - Parameters:
    ///   - cardId: идентификатор сохраненной карты
    ///   - cvv: код `CVV` в виде строки.
    case savedCard(cardId: String, cvv: String?)

    /// при оплате на основе родительского платежа
    ///
    /// - Parameters:
    ///   - rebuidId: идентификатор родительского платежа
    case parentPayment(rebuidId: String)

    /// при оплате с помощью **ApplePay**
    ///
    /// - Parameters:
    ///   - string: UTF-8 encoded JSON dictionary of encrypted payment data from `PKPaymentToken.paymentData`
    case paymentData(String)

    case unknown

    // MARK: Coding Logic

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = .unknown

        if let number = try? container.decode(String.self, forKey: .cardNumber),
           let expDate = try? container.decode(String.self, forKey: .cardExpDate),
           let cvv = try? container.decode(String.self, forKey: .cardCVV) {
            self = .cardNumber(number: number, expDate: expDate, cvv: cvv)
        } else if let cardId = try? container.decode(String.self, forKey: .savedCardId) {
            let cvv = try? container.decode(String.self, forKey: .cardCVV)
            self = .savedCard(cardId: cardId, cvv: cvv)
        } else if let paymentDataString = try? container.decode(String.self, forKey: .paymentData) {
            self = .paymentData(paymentDataString)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .cardNumber(number, expData, cvv):
            try container.encode(number, forKey: .cardNumber)
            try container.encode(expData, forKey: .cardExpDate)
            try container.encode(cvv, forKey: .cardCVV)

        case let .savedCard(cardId, cvv):
            try container.encode(cardId, forKey: .savedCardId)
            try container.encode(cvv, forKey: .cardCVV)

        case let .paymentData(data):
            try container.encode(data, forKey: .paymentData)

        default:
            break
        }
    }

    // MARK: Helpers

    func getCardAndRebillId() -> (cardId: String?, rebillId: String?) {
        switch self {
        case let .parentPayment(rebillId):
            return (nil, rebillId)
        case let .savedCard(cardId, _):
            return (cardId, nil)
        default:
            return (nil, nil)
        }
    }
}
