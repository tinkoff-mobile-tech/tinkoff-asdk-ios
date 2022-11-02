//
//
//  ThreeDSWebViewHandler.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public protocol IThreeDSWebViewHandler: AnyObject {
    var onUserTapCloseButton: (() -> Void)? { get set }

    func handle<Payload: Decodable>(
        urlString: String,
        responseData data: Data
    ) throws -> ThreeDSHandleResult<Payload>
}

public enum ThreeDSHandleResult<Payload: Decodable> {
    case finished(payload: Payload)
    case cancelled
}

public final class ThreeDSWebViewHandler<Payload: Decodable>: IThreeDSWebViewHandler {

    enum ThreeDSError: Swift.Error {
        case hasNoConfirmationUrlSuffix
    }

    public var onUserTapCloseButton: (() -> Void)?

    private let urlBuilder: IThreeDSURLBuilder
    private let decoder: IAcquiringDecoder

    init(
        urlBuilder: IThreeDSURLBuilder,
        decoder: IAcquiringDecoder
    ) {
        self.urlBuilder = urlBuilder
        self.decoder = decoder
    }

    public func handle<Payload: Decodable>(
        urlString: String,
        responseData data: Data
    ) throws -> ThreeDSHandleResult<Payload> {

        guard !urlString.hasSuffix("cancel.do") else {
            return .cancelled
        }

        let confirmation3DSTerminationURLString = urlBuilder
            .url(ofType: .confirmation3DSTerminationURL)
            .absoluteString

        let confirmation3DSTerminationV2URLString = urlBuilder
            .url(ofType: .confirmation3DSTerminationV2URL)
            .absoluteString

        guard urlString.hasSuffix(confirmation3DSTerminationURLString) || urlString.hasSuffix(confirmation3DSTerminationV2URLString) else {
            throw ThreeDSError.hasNoConfirmationUrlSuffix
        }

        let payload = try decoder.decode(Payload.self, from: data, with: .standard)
        return ThreeDSHandleResult.finished(payload: payload)
    }
}
