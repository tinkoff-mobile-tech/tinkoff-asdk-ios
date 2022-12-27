//
//  YandexPaySDK+DataMapping.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation
import TinkoffASDKUI
import YandexPaySDK

extension YandexPayButtonConfiguration {
    static func from(_ configuration: YandexPayButtonContainerConfiguration) -> YandexPayButtonConfiguration {
        YandexPayButtonConfiguration(theme: .from(configuration.theme))
    }
}

extension YandexPayButtonTheme {
    static func from(_ theme: YandexPayButtonContainerTheme) -> YandexPayButtonTheme {
        if #available(iOS 13, *) {
            return YandexPaySDK.YandexPayButtonTheme(appearance: .from(theme.appearance), dynamic: theme.dynamic)
        } else {
            return YandexPaySDK.YandexPayButtonTheme(appearance: .from(theme.appearance))
        }
    }
}

extension YandexPayButtonApperance {
    static func from(_ appearance: YandexPayButtonContainerAppearance) -> YandexPayButtonApperance {
        switch appearance {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

extension YandexPaySDK.YandexPaySDKEnvironment {
    static func from(_ environment: TinkoffASDKUI.YandexPaySDKConfiguration.Environment) -> YandexPaySDK.YandexPaySDKEnvironment {
        switch environment {
        case .production:
            return .production
        case .sandbox:
            return .sandbox
        }
    }
}

extension YandexPaySDK.YandexPaySDKLocale {
    static func from(_ locale: TinkoffASDKUI.YandexPaySDKConfiguration.Locale) -> YandexPaySDK.YandexPaySDKLocale {
        switch locale {
        case .ru:
            return .ru
        case .en:
            return .en
        case .system:
            return .system
        }
    }
}
