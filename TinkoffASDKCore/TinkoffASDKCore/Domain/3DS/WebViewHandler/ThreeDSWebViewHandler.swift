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

public enum ThreeDSWebViewHandlingResult<Payload: Decodable> {
    case finished(payload: Result<Payload, Error>)
    case cancelled
}

public protocol IThreeDSWebViewHandler: AnyObject {
    func handle<Payload: Decodable>(
        urlString: String,
        responseData data: Data
    ) -> ThreeDSWebViewHandlingResult<Payload>?
}

public final class ThreeDSWebViewHandler: IThreeDSWebViewHandler {
    // MARK: Dependencies

    private let urlBuilder: IThreeDSURLBuilder
    private let decoder: IAcquiringDecoder

    // MARK: Init

    init(
        urlBuilder: IThreeDSURLBuilder,
        decoder: IAcquiringDecoder
    ) {
        self.urlBuilder = urlBuilder
        self.decoder = decoder
    }

    // MARK: IThreeDSWebViewHandler

    public func handle<Payload: Decodable>(
        urlString: String,
        responseData data: Data
    ) -> ThreeDSWebViewHandlingResult<Payload>? {

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
            return nil
        }

        let payloadResult = Result {
            try decoder.decode(Payload.self, from: data, with: .standard)
        }

        return ThreeDSWebViewHandlingResult.finished(payload: payloadResult)
    }
}
