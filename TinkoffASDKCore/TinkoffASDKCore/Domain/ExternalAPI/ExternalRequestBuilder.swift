//
//  ExternalRequestBuilder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 06.10.2022.
//

import Foundation

protocol IExternalRequestBuilder {
    func get3DSAppBasedConfigRequest() -> NetworkRequest
}

final class ExternalRequestBuilder: IExternalRequestBuilder {
    private let appBasedConfigURLProvider: IURLProvider

    init(appBasedConfigURLProvider: IURLProvider) {
        self.appBasedConfigURLProvider = appBasedConfigURLProvider
    }

    func get3DSAppBasedConfigRequest() -> NetworkRequest {
        Get3DSAppBasedCertsConfigRequest(baseURL: appBasedConfigURLProvider.url)
    }
}
