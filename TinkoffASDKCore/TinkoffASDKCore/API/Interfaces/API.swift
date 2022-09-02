//
//
//  API.swift
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

protocol API {
    func performRequest<Request: APIRequest>(_ request: Request,
                                             completion: @escaping (Swift.Result<Request.Payload, Error>) -> Void) -> Cancellable
    func performDeprecatedRequest<Request: APIRequest, Response: ResponseOperation>(_ request: Request,
                                                                                    delegate: NetworkTransportResponseDelegate?,
                                                                                    completion: @escaping (Result<Response, Error>) -> Void) -> Cancellable
    func sendCertsConfigRequest(
        _ request: NetworkRequest,
        completionHandler: @escaping (Result<GetCertsConfigResponse, Error>) -> Void
    ) -> Cancellable
}

extension API {
    func performDeprecatedRequest<Request: APIRequest, Response: ResponseOperation>(_ request: Request,
                                                                                    completion: @escaping (Result<Response, Error>) -> Void) -> Cancellable {
        performDeprecatedRequest(request, delegate: nil, completion: completion)
    }
}
