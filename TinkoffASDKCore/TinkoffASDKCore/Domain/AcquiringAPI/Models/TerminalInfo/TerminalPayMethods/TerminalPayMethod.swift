//
//  TerminalPayMethod.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 29.11.2022.
//

import Foundation

/// Метод оплаты, доступный для данного терминала
public enum TerminalPayMethod {
    /// Оплата с помощью YandexPay
    case yandexPay(YandexPayMethod)
}

// MARK: - TerminalPayMethod + Decodable

extension TerminalPayMethod: Decodable {
    private enum CodingKeys: String, CodingKey {
        case payMethod = "PayMethod"
        case params = "Params"
    }

    private enum MethodType: String, Decodable {
        case yandexPay = "YandexPay"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let methodType = try container.decode(MethodType.self, forKey: .payMethod)

        switch methodType {
        case .yandexPay:
            self = .yandexPay(try container.decode(YandexPayMethod.self, forKey: .params))
        }
    }
}
