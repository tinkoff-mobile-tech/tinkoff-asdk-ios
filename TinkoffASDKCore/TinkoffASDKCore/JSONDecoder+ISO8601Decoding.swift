//
//
//  JSONDecoder+ISO8601Decoding.swift
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

// MARK: - JSONDecoder + Custom ISO8601 Date Decoding

private enum DateDecodingError: Error {
    case invalidDate
}

extension JSONDecoder {
    static var customISO8601Decoding: JSONDecoder {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime
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
