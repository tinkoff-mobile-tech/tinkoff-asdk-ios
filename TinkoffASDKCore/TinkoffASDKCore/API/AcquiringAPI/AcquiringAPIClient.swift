//
//
//  AcquiringAPIClient.swift
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

protocol IAcquiringAPIClient {
    func performRequest<Payload: Decodable>(
        _ request: APIRequest,
        completion: @escaping (Result<Payload, Error>) -> Void
    ) -> Cancellable

    @available(*, deprecated, message: "Use performRequest(_:completion:) instead")
    func performDeprecatedRequest<Response: ResponseOperation>(
        _ request: APIRequest,
        delegate: NetworkTransportResponseDelegate?,
        completion: @escaping (Result<Response, Error>) -> Void
    ) -> Cancellable
}

final class AcquiringAPIClient: IAcquiringAPIClient {
    private let networkClient: INetworkClient
    private let apiDecoder: IAPIDecoder
    @available(*, deprecated, message: "Use apiDecoder instead")
    private let deprecatedDecoder = DeprecatedDecoder()

    init(
        networkClient: INetworkClient,
        apiDecoder: IAPIDecoder
    ) {
        self.networkClient = networkClient
        self.apiDecoder = apiDecoder
    }

    // MARK: API

    func performRequest<Payload: Decodable>(
        _ request: APIRequest,
        completion: @escaping (Swift.Result<Payload, Error>) -> Void
    ) -> Cancellable {
        networkClient.performRequest(request) { [apiDecoder] response in
            let result = response.result.tryMap { data in
                try apiDecoder.decode(Payload.self, from: data, with: request.decodingStrategy)
            }

            completion(result)
            //            do {
            //                let data = try response.result.get()
            //                self.handleResponseData(
            //                    data,
            //                    for: request,
            //                    completion: completion
            //                )
            //            } catch {
            //                completion(.failure(error))
            //            }
        }
    }

    @available(*, deprecated, message: "Use performRequest(_:completion:) instead")
    func performDeprecatedRequest<Response: ResponseOperation>(
        _ request: APIRequest,
        delegate: NetworkTransportResponseDelegate?,
        completion: @escaping (Result<Response, Error>) -> Void
    ) -> Cancellable {

        networkClient.performRequest(request) { [deprecatedDecoder] response in
            let result: Result<Response, Error> = response.result.tryMap { data in
                if let delegate = delegate,
                   let urlRequest = response.request,
                   let httpResponse = response.response {

                    guard let delegatedResponse = try? delegate.networkTransport(
                        didCompleteRawTaskForRequest: urlRequest,
                        withData: data,
                        response: httpResponse,
                        error: response.error
                    ) else {
                        throw HTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
                    }
                    // swiftlint:disable:next force_cast
                    return delegatedResponse as! Response
                }

                return try deprecatedDecoder.decode(data: data, with: response.response)
            }

            completion(result)
        }
    }

    // MARK: Helpers

//    private func handleResponseData<Request: APIRequest>(
//        _ data: Data,
//        for request: Request,
//        completion: @escaping (Swift.Result<Request.Payload, Error>) -> Void
//    ) {
//        do {
//            let apiResponse = try apiResponseDecoder.decode(data: data, for: request)
//            let payload = try apiResponse.result.get()
//            completion(.success(payload))
//        } catch let apiFailureError as APIFailureError {
//            completion(.failure(APIError.failure(apiFailureError)))
//        } catch {
//            completion(.failure(APIError.invalidResponse))
//        }
//    }
}

private final class DeprecatedDecoder {
    private let decoder = JSONDecoder()

    func decode<Response: ResponseOperation>(data: Data, with response: HTTPURLResponse?) throws -> Response {
        let response = try response.orThrow(NSError(domain: "Response must exist", code: 1))

        // decode as a default `AcquiringResponse`
        guard let acquiringResponse = try? decoder.decode(AcquiringResponse.self, from: data) else {
            throw HTTPResponseError(body: data, response: response, kind: .invalidResponse)
        }

        // data  in `AcquiringResponse` format but `Success = 0;` ( `false` )
        guard acquiringResponse.success else {
            var errorMessage: String = Loc.TinkoffAcquiring.Response.Error.statusFalse

            if let message = acquiringResponse.errorMessage {
                errorMessage = message
            }

            if let details = acquiringResponse.errorDetails, details.isEmpty == false {
                errorMessage.append(contentsOf: " ")
                errorMessage.append(contentsOf: details)
            }

            let error = NSError(
                domain: errorMessage,
                code: acquiringResponse.errorCode,
                userInfo: try? acquiringResponse.encode2JSONObject()
            )

            throw error
        }

        // decode to `Response`
        if let responseObject: Response = try? decoder.decode(Response.self, from: data) {
            return responseObject
        } else {
            throw HTTPResponseError(body: data, response: response, kind: .invalidResponse)
        }
    }
}
