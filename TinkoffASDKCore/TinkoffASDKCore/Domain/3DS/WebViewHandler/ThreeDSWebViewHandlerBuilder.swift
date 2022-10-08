//
//  ThreeDSWebViewHandlerBuilder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 08.10.2022.
//

import Foundation

protocol IThreeDSWebViewHandlerBuilder {
    func threeDSWebViewHandler<Payload: Decodable>() -> ThreeDSWebViewHandler<Payload>
}

final class ThreeDSWebViewHandlerBuilder: IThreeDSWebViewHandlerBuilder {
    private let threeDSURLBuilder: IThreeDSURLBuilder
    private let decoder: JSONDecoder

    init(threeDSURLBuilder: IThreeDSURLBuilder, decoder: JSONDecoder) {
        self.threeDSURLBuilder = threeDSURLBuilder
        self.decoder = decoder
    }

    func threeDSWebViewHandler<Payload>() -> ThreeDSWebViewHandler<Payload> where Payload: Decodable {
        ThreeDSWebViewHandler(
            urlBuilder: threeDSURLBuilder,
            jsonDecoder: decoder
        )
    }
}
