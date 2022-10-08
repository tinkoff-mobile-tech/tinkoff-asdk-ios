//
//  ThreeDSFacade.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 08.10.2022.
//

import Foundation

typealias IThreeDSFacade = IThreeDSURLBuilder & IThreeDSURLRequestBuilder & IThreeDSWebViewHandlerBuilder & IThreeDSDeviceParamsProviderBuilder

final class ThreeDSFacade {
    private let threeDSURLBuilder: IThreeDSURLBuilder
    private let threeDSURLRequestBuilder: IThreeDSURLRequestBuilder
    private let webViewHandlerBuilder: IThreeDSWebViewHandlerBuilder
    private let deviceParamsProviderBuilder: IThreeDSDeviceParamsProviderBuilder

    init(
        threeDSURLBuilder: IThreeDSURLBuilder,
        threeDSURLRequestBuilder: IThreeDSURLRequestBuilder,
        webViewHandlerBuilder: IThreeDSWebViewHandlerBuilder,
        deviceParamsProviderBuilder: IThreeDSDeviceParamsProviderBuilder
    ) {
        self.threeDSURLBuilder = threeDSURLBuilder
        self.threeDSURLRequestBuilder = threeDSURLRequestBuilder
        self.webViewHandlerBuilder = webViewHandlerBuilder
        self.deviceParamsProviderBuilder = deviceParamsProviderBuilder
    }
}

// MARK: - IThreeDSURLBuilder

extension ThreeDSFacade: IThreeDSURLBuilder {
    func url(ofType type: ThreeDSURLType) -> URL {
        threeDSURLBuilder.url(ofType: type)
    }
}

// MARK: - IThreeDSURLRequestBuilder

extension ThreeDSFacade: IThreeDSURLRequestBuilder {
    func buildConfirmation3DSRequestACS(requestData: Confirmation3DSDataACS, version: String) throws -> URLRequest {
        try threeDSURLRequestBuilder.buildConfirmation3DSRequestACS(requestData: requestData, version: version)
    }

    func buildConfirmation3DSRequest(requestData: Confirmation3DSData) throws -> URLRequest {
        try threeDSURLRequestBuilder.buildConfirmation3DSRequest(requestData: requestData)
    }

    func build3DSCheckURLRequest(requestData: Checking3DSURLData) throws -> URLRequest {
        try threeDSURLRequestBuilder.build3DSCheckURLRequest(requestData: requestData)
    }
}

// MARK: - IThreeDSWebViewHandlerBuilder

extension ThreeDSFacade: IThreeDSWebViewHandlerBuilder {
    func threeDSWebViewHandler<Payload: Decodable>() -> ThreeDSWebViewHandler<Payload> {
        webViewHandlerBuilder.threeDSWebViewHandler()
    }
}

// MARK: - IThreeDSDeviceParamsProviderBuilder

extension ThreeDSFacade: IThreeDSDeviceParamsProviderBuilder {
    func deviceParamsProvider(screenSize: CGSize) -> ThreeDSDeviceParamsProvider {
        deviceParamsProviderBuilder.deviceParamsProvider(screenSize: screenSize)
    }
}
