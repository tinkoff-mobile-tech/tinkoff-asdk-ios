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

/// Определяет логику декодирования ответов API эквайринга
enum AcquiringDecodingStrategy {
    /// Декодирование, учитывающая параметры в JSON: `Success`, `ErrorCode`, `ErrorMessage` и тд
    /// Используется для большинства ответов API эквайринга
    case standard
    /// Декодирование, игнорирующая дополнительные параметры в JSON.
    /// Используется для нестандартных ответов, например в методе `GetCardList`
    case clipped
}

/// Определяет логику формирования токена для запроса
enum TokenFormationStrategy: Equatable {
    /// Токен формируется на основе всех параметров, за исключением набора `exceptParameters`
    case includeAll(exceptParameters: Set<String>)
    /// Токен не формируется
    case none

    /// Токен формируется на основе всех параметров, за исключением набора `exceptParameters`
    /// - Parameter exceptParameters: Набор параметров, которое будут игнорироваться при формировании токена
    static func includeAll(except exceptParameters: String...) -> TokenFormationStrategy {
        .includeAll(exceptParameters: Set(exceptParameters))
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
    /// Определяет логику декодирования ответов API эквайринга
    var decodingStrategy: AcquiringDecodingStrategy { get }
    /// Определяет необходимость добавления параметра `TerminalKey` к параметрам запроса
    var terminalKeyProvidingStrategy: TerminalKeyProvidingStrategy { get }
    /// Определяет логику формирования токена для запроса
    var tokenFormationStrategy: TokenFormationStrategy { get }
}

extension AcquiringRequest {
    var decodingStrategy: AcquiringDecodingStrategy { .standard }
}
