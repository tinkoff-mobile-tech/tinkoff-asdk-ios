//
//  ThreeDSDeviceParamsProviderBuilder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 08.10.2022.
//

import Foundation
import struct UIKit.CGSize

protocol IThreeDSDeviceParamsProviderBuilder {
    func deviceParamsProvider(screenSize: CGSize) -> ThreeDSDeviceParamsProvider
}

final class ThreeDSDeviceParamsProviderBuilder: IThreeDSDeviceParamsProviderBuilder {
    private let languageProvider: ILanguageProvider
    private let urlBuilder: IThreeDSURLBuilder

    init(languageProvider: ILanguageProvider, urlBuilder: IThreeDSURLBuilder) {
        self.languageProvider = languageProvider
        self.urlBuilder = urlBuilder
    }

    func deviceParamsProvider(screenSize: CGSize) -> ThreeDSDeviceParamsProvider {
        DefaultThreeDSDeviceParamsProvider(
            screenSize: screenSize,
            languageProvider: languageProvider,
            urlBuilder: urlBuilder
        )
    }
}
