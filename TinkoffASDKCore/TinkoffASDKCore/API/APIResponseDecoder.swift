//
//
//  APIResponseDecoder.swift
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

protocol IAPIResponseDecoder {
    func decode<Request: APIRequest>(data: Data, for request: Request) throws -> APIResponse<Request.Payload>
}

final class APIResponseDecoder: IAPIResponseDecoder {
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    // MARK: IAPIResponseDecoder

    func decode<Request: APIRequest>(data: Data, for request: Request) throws -> APIResponse<Request.Payload> {
        switch request.decodingStrategy {
        case .standard:
            return try decodeStandard(data: data)
        case .clipped:
            return try decodeClipped(data: data)
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
