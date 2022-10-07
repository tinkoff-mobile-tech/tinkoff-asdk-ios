//
//  ExternalRequestsBuilder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 06.10.2022.
//

import Foundation

protocol IExternalRequestsBuilder {
    func get3DSAppBasedConfigRequest() -> NetworkRequest
}

final class ExternalRequestsBuilder: IExternalRequestsBuilder {
    private let appBasedConfigURLProvider: IURLProvider

    init(appBasedConfigURLProvider: IURLProvider) {
        self.appBasedConfigURLProvider = appBasedConfigURLProvider
    }

    func get3DSAppBasedConfigRequest() -> NetworkRequest {
        Get3DSAppBasedCertsConfigRequest(baseURL: appBasedConfigURLProvider.url)
    }
}
