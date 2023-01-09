//
//  IYandexPaySDKInitializable.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 02.12.2022.
//

import class YandexPaySDK.YandexPaySDKConfiguration

protocol IYandexPaySDKInitializable {
    var isInitialized: Bool { get }
    func initialize(configuration: YandexPaySDK.YandexPaySDKConfiguration) throws
}
