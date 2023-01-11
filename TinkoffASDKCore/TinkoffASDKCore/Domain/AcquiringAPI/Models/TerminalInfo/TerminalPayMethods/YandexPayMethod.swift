//
//  YandexPayMethod.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 29.11.2022.
//

import Foundation

/// Данные для оплаты с помощью YandexPay
public struct YandexPayMethod {
    /// ID продавца для создания платежной формы YandexPay (`YPCardPaymentMethod.gatewayMerchantId`)
    public let merchantId: String
    /// Имя продавца для инициализации YandexPay (`YandexPaySDKMerchant.name`)
    public let merchantName: String
    /// URL продавца для инициализации YandexPay  (`YandexPaySDKMerchant.url`)
    public let merchantOrigin: String
    /// ID продавца для инициализации YandexPay (`YandexPaySDKMerchant.id`)
    public let showcaseId: String

    /// Инициализация данных для оплаты с помощью YandexPay
    public init(
        merchantId: String,
        merchantName: String,
        merchantOrigin: String,
        showcaseId: String
    ) {
        self.merchantId = merchantId
        self.merchantName = merchantName
        self.merchantOrigin = merchantOrigin
        self.showcaseId = showcaseId
    }
}

// MARK: - YandexPayMethod + Decodable

extension YandexPayMethod: Decodable {
    private enum CodingKeys: String, CodingKey {
        case merchantId = "MerchantId"
        case merchantName = "MerchantName"
        case merchantOrigin = "MerchantOrigin"
        case showcaseId = "ShowcaseId"
    }
}
