//
//  TerminalPayMethod.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 29.11.2022.
//

import Foundation

/// Метод оплаты, доступный для данного терминала
public enum TerminalPayMethod {
    /// Оплата с помощью `YandexPay`
    case yandexPay(YandexPayMethod)
    /// Оплата с помощью `СБП`
    case sbp
    /// Оплата с помощью `TinkoffPay`
    case tinkoffPay(TinkoffPayMethod)
}

// MARK: - TerminalPayMethod + Decodable

extension TerminalPayMethod: Decodable {
    private enum CodingKeys: String, CodingKey {
        case payMethod = "PayMethod"
        case params = "Params"
        case version = "Version"
    }

    private enum MethodType: String, Decodable {
        case yandexPay = "YandexPay"
        case sbp = "SBP"
        case tinkoffPay = "TinkoffPay"
    }

    private enum TinkoffPayParams: String, CodingKey {
        case version = "Version"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let methodType = try container.decode(MethodType.self, forKey: .payMethod)

        switch methodType {
        case .yandexPay:
            self = .yandexPay(try container.decode(YandexPayMethod.self, forKey: .params))
        case .sbp:
            self = .sbp
        case .tinkoffPay:
            self = .tinkoffPay(try container.decode(TinkoffPayMethod.self, forKey: .params))
        }
    }
}
