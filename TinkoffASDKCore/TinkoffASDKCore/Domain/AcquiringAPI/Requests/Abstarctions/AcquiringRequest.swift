//
//
//  AcquiringRequest.swift
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

enum AcquiringDecodingStrategy {
    case standard
    case clipped
}

enum TokenFormationStrategy: Equatable {
    case includeAll(exceptParameters: Set<String>)
    case none
}

extension TokenFormationStrategy {
    static func includeAll(except parameters: String...) -> TokenFormationStrategy {
        .includeAll(exceptParameters: Set(parameters))
    }
}

/// Определяет необходимость добавления параметра `TerminalKey` к параметрам запроса
enum TerminalKeyProvidingStrategy {
    /// Всегда добавляет `TerminalKey` к параметрам запроса
    case always
    /// `TerminalKey` не участвует в формировании запроса
    case never
}

protocol AcquiringRequest: NetworkRequest {
    var decodingStrategy: AcquiringDecodingStrategy { get }
    /// Определяет необходимость добавления параметра `TerminalKey` к параметрам запроса
    var terminalKeyProvidingStrategy: TerminalKeyProvidingStrategy { get }
    var tokenFormationStrategy: TokenFormationStrategy { get }
}

extension AcquiringRequest {
    var decodingStrategy: AcquiringDecodingStrategy { .standard }
}
