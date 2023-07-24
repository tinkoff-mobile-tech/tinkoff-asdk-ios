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
    private let appBasedSdkUiProvider: IAppBasedSdkUiProvider

    init(
        languageProvider: ILanguageProvider,
        urlBuilder: IThreeDSURLBuilder,
        appBasedSdkUiProvider: IAppBasedSdkUiProvider
    ) {
        self.languageProvider = languageProvider
        self.urlBuilder = urlBuilder
        self.appBasedSdkUiProvider = appBasedSdkUiProvider
    }

    func threeDSDeviceInfoProvider() -> IThreeDSDeviceInfoProvider {
        ThreeDSDeviceInfoProvider(
            languageProvider: languageProvider,
            urlBuilder: urlBuilder,
            sdkUiProvider: appBasedSdkUiProvider
        )
    }
}
