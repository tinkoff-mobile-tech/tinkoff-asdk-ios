//
//  ExternalAPIClient.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 05.10.2022.
//

import Foundation

protocol IExternalAPIClient {
    func perform<Payload: Decodable>(
        _ request: NetworkRequest,
        completion: @escaping (Result<Payload, Error>) -> Void
    ) -> Cancellable
}

final class ExternalAPIClient: IExternalAPIClient {
    private let networkClient: INetworkClient
    private let decoder: JSONDecoder

    init(networkClient: INetworkClient, decoder: JSONDecoder = .customISO8601Decoding) {
        self.networkClient = networkClient
        self.decoder = decoder
    }

    func perform<Payload: Decodable>(
        _ request: NetworkRequest,
        completion: @escaping (Result<Payload, Error>) -> Void
    ) -> Cancellable {
        networkClient.performRequest(request) { [decoder] networkResult in
            let result = networkResult.tryMap { response in
                try decoder.decode(Payload.self, from: response.data)
            }

            completion(result)
        }
    }
}

// MARK: JSONDecoder + CustomISO8601Decoding

private extension JSONDecoder {
    private enum DateDecodingError: Error {
        case invalidDate
    }

    /// Используется кастомная логика парсинга даты для запроса `Get3DSAppBasedCertsConfigRequest`,
    /// в остальных случаях даты в полях не приходят
    static var customISO8601Decoding: JSONDecoder {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
        ]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let stringDate = try container.decode(String.self)
            return try formatter.date(from: stringDate).orThrow(DateDecodingError.invalidDate)
        }
        return decoder
    }
}
