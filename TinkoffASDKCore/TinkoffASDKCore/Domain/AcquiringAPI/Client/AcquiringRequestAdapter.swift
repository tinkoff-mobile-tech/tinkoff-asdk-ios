//
//  AcquiringRequestAdapter.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 06.10.2022.
//

import Foundation

protocol IAcquiringRequestAdapter {
    func adapt(
        request: AcquiringRequest,
        completion: @escaping (Result<AcquiringRequest, Error>) -> Void
    )
}

final class AcquiringRequestAdapter: IAcquiringRequestAdapter {
    fileprivate struct AdaptedRequest: AcquiringRequest {
        let baseURL: URL
        let path: String
        let httpMethod: HTTPMethod
        var parameters: HTTPParameters
        let headers: HTTPHeaders
        let decodingStrategy: AcquiringDecodingStrategy
    }

    private let terminalKeyProvider: IStringProvider

    init(terminalKeyProvider: IStringProvider) {
        self.terminalKeyProvider = terminalKeyProvider
    }

    func adapt(
        request: AcquiringRequest,
        completion: @escaping (Result<AcquiringRequest, Error>) -> Void
    ) {
        guard !request.parameters.isEmpty else {
            return completion(.success(request))
        }

        var adaptedRequest = AdaptedRequest.copy(request: request)

        adaptedRequest
            .parameters
            .merge([Constants.Keys.terminalKey: terminalKeyProvider.value]) { $1 }

        completion(.success(adaptedRequest))
    }
}

private extension AcquiringRequestAdapter.AdaptedRequest {
    static func copy(request: AcquiringRequest) -> AcquiringRequestAdapter.AdaptedRequest {
        AcquiringRequestAdapter.AdaptedRequest(
            baseURL: request.baseURL,
            path: request.path,
            httpMethod: request.httpMethod,
            parameters: request.parameters,
            headers: request.headers,
            decodingStrategy: request.decodingStrategy
        )
    }
}
