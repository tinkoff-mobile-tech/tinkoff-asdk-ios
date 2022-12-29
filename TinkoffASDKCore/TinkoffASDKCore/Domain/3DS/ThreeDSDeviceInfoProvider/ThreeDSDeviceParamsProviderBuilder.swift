//
//  ThreeDSDeviceParamsProviderBuilder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 08.10.2022.
//

import Foundation
import struct UIKit.CGSize

protocol IThreeDSDeviceParamsProviderBuilder {
    func threeDSDeviceInfoProvider() -> IThreeDSDeviceInfoProvider
}

final class ThreeDSDeviceParamsProviderBuilder: IThreeDSDeviceParamsProviderBuilder {
    private let languageProvider: ILanguageProvider
    private let urlBuilder: IThreeDSURLBuilder

    init(languageProvider: ILanguageProvider, urlBuilder: IThreeDSURLBuilder) {
        self.languageProvider = languageProvider
        self.urlBuilder = urlBuilder
    }

    func threeDSDeviceInfoProvider() -> IThreeDSDeviceInfoProvider {
        ThreeDSDeviceInfoProvider(
            languageProvider: languageProvider,
            urlBuilder: urlBuilder
        )
    }
}
