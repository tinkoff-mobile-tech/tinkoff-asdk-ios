//
//  AcquiringRequestAdapter.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 06.10.2022.
//

import Foundation

protocol IAcquiringRequestAdapter {
    func adapt(
        request: APIRequest,
        completion: @escaping (Result<APIRequest, Error>) -> Void
    )
}

final class AcquiringRequestAdapter: IAcquiringRequestAdapter {
    fileprivate struct AdaptedRequest: APIRequest {
        let baseURL: URL
        let path: String
        let httpMethod: HTTPMethod
        var parameters: HTTPParameters
        let parametersEncoding: HTTPParametersEncoding
        let headers: HTTPHeaders
        let decodingStrategy: AcquiringDecodingStrategy
    }

    private let terminalKey: String

    init(terminalKey: String) {
        self.terminalKey = terminalKey
    }

    func adapt(
        request: APIRequest,
        completion: @escaping (Result<APIRequest, Error>) -> Void
    ) {
        guard !request.parameters.isEmpty else {
            return completion(.success(request))
        }

        var adaptedRequest = AdaptedRequest.copy(request: request)

        adaptedRequest
            .parameters
            .merge([APIConstants.Keys.terminalKey: terminalKey]) { $1 }

        completion(.success(adaptedRequest))
    }
}

private extension AcquiringRequestAdapter.AdaptedRequest {
    static func copy(request: APIRequest) -> AcquiringRequestAdapter.AdaptedRequest {
        AcquiringRequestAdapter.AdaptedRequest(
            baseURL: request.baseURL,
            path: request.path,
            httpMethod: request.httpMethod,
            parameters: request.parameters,
            parametersEncoding: request.parametersEncoding,
            headers: request.headers,
            decodingStrategy: request.decodingStrategy
        )
    }
}
