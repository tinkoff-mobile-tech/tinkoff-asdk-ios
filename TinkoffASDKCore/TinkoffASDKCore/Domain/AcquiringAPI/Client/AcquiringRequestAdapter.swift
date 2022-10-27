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
    // MARK: Dependencies

    private let terminalKeyProvider: IStringProvider
    private let tokenProvider: ITokenProvider?

    // MARK: Init

    init(terminalKeyProvider: IStringProvider, tokenProvider: ITokenProvider?) {
        self.terminalKeyProvider = terminalKeyProvider
        self.tokenProvider = tokenProvider
    }

    // MARK: IAcquiringRequestAdapter

    func adapt(
        request: AcquiringRequest,
        completion: @escaping (Result<AcquiringRequest, Error>) -> Void
    ) {
        guard !request.parameters.isEmpty else {
            return completion(.success(request))
        }

        let requestWithTerminalKey = request.adapted(withTerminalKey: terminalKeyProvider.value)

        switch request.tokenFormationStrategy {
        case .none:
            completion(.success(requestWithTerminalKey))
        case let .includeAll(excludingParams):
            adaptWithToken(
                request: requestWithTerminalKey,
                excludingParameters: excludingParams,
                completion: completion
            )
        }
    }

    // MARK: Helpers

    private func adaptWithToken(
        request: AcquiringRequest,
        excludingParameters: Set<String>,
        completion: @escaping (Result<AcquiringRequest, Error>) -> Void
    ) {
        guard let tokenProvider = tokenProvider else {
            return completion(.success(request))
        }

        let tokenParameters = request
            .parameters
            .filter { !excludingParameters.contains($0.key) }
            .mapValues { String(describing: $0) }

        tokenProvider.provideToken(forRequestParameters: tokenParameters) { tokenResult in
            let result = tokenResult.map(request.adapted(withToken:))
            completion(result)
        }
    }
}

// MARK: - AdaptedRequest

private struct AdaptedRequest: AcquiringRequest {
    let baseURL: URL
    let path: String
    let httpMethod: HTTPMethod
    let headers: HTTPHeaders
    let parameters: HTTPParameters
    let parametersEncoding: ParametersEncoding
    let decodingStrategy: AcquiringDecodingStrategy
    let tokenFormationStrategy: TokenFormationStrategy
}

// MARK: - AcquiringRequest + Adaptation

private extension AcquiringRequest {
    func adapted(withTerminalKey terminalKey: String) -> AcquiringRequest {
        adapted(mergingParameters: [Constants.Keys.terminalKey: terminalKey])
    }

    func adapted(withToken token: String) -> AcquiringRequest {
        adapted(mergingParameters: [Constants.Keys.token: token])
    }

    private func adapted(mergingParameters: HTTPParameters = [:]) -> AcquiringRequest {
        AdaptedRequest(
            baseURL: baseURL,
            path: path,
            httpMethod: httpMethod,
            headers: headers,
            parameters: parameters.merging(mergingParameters) { $1 },
            parametersEncoding: parametersEncoding,
            decodingStrategy: decodingStrategy,
            tokenFormationStrategy: tokenFormationStrategy
        )
    }
}
