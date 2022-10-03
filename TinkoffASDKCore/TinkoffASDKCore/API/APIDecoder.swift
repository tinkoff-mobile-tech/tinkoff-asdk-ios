//
//
//  APIDecoder.swift
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

protocol IAPIDecoder {
    func decode<Payload: Decodable>(
        _ type: Payload.Type,
        from data: Data,
        with strategy: APIDecodingStrategy
    ) throws -> Payload
}

final class APIDecoder: IAPIDecoder {
    private let decoder: JSONDecoder = .customISO8601Decoding

    // MARK: IAPIDecoder

    func decode<Payload: Decodable>(
        _ type: Payload.Type,
        from data: Data,
        with strategy: APIDecodingStrategy
    ) throws -> Payload {
        switch strategy {
        case .acquiring(.standard):
            return try decodeStandard(data: data).result.get()
        case .acquiring(.clipped):
            return try decodeClipped(data: data).result.get()
        case .plain:
            return try decoder.decode(type, from: data)
        }
    }

    // MARK: Helpers

    private func decodeStandard<Payload: Decodable>(data: Data) throws -> APIResponse<Payload> {
        return try decoder.decode(APIResponse<Payload>.self, from: data)
    }

    private func decodeClipped<Payload: Decodable>(data: Data) throws -> APIResponse<Payload> {
        do {
            let error = try? decoder.decode(APIFailureError.self, from: data)

            if let error = error, error.errorCode != 0 {
                return APIResponse(
                    success: false,
                    errorCode: error.errorCode,
                    terminalKey: nil,
                    result: .failure(error)
                )
            } else {
                let payload = try decoder.decode(Payload.self, from: data)
                return APIResponse(
                    success: true,
                    errorCode: 0,
                    terminalKey: nil,
                    result: .success(payload)
                )
            }
        } catch {
            return try decodeStandard(data: data)
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
