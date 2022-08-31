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

public final class ThreeDSWebViewHandler<Payload: Decodable> {
    public var didCancel: (() -> Void)?
    public var didFinish: ((Result<Payload, Error>) -> Void)?
    
    private let threeDSURLBuilder: ThreeDSURLBuilder
    private let jsonDecoder: JSONDecoder
    
    init(threeDSURLBuilder: ThreeDSURLBuilder,
         jsonDecoder: JSONDecoder) {
        self.threeDSURLBuilder = threeDSURLBuilder
        self.jsonDecoder = jsonDecoder
    }
    
    public func handle(urlString: String, responseData data: Data) {
        guard !urlString.hasSuffix("cancel.do") else {
            didCancel?()
            return
        }
        
        guard let confirmation3DSTerminationURLString = try? threeDSURLBuilder.buildURL(type: .confirmation3DSTerminationURL).absoluteString,
              let confirmation3DSTerminationV2URLString = try? threeDSURLBuilder.buildURL(type: .confirmation3DSTerminationV2URL).absoluteString
        else {
            return
        }
        
        guard urlString.hasSuffix(confirmation3DSTerminationURLString) || urlString.hasSuffix(confirmation3DSTerminationV2URLString) else {
            return
        }
        
        do {
            let response = try jsonDecoder.decode(APIResponse<Payload>.self, from: data)
            switch response.result {
            case let .success(payload):
                didFinish?(.success(payload))
            case let .failure(error):
                didFinish?(.failure(error))
            }
        } catch {
            didFinish?(.failure(APIError.invalidResponse))
        }
    }
}
