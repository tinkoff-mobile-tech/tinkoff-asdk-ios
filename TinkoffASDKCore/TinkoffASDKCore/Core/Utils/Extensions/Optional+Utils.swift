//
//
//  Optional+Utils.swift
//
//  Copyright (c) 2022 Tinkoff Bank
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

extension Optional {
    /// Разворачивает опциональное значение или выбрасывает заданный `Error`
    func orThrow<E: Error>(_ error: @autoclosure () -> E) throws -> Wrapped {
        guard let self = self else {
            throw error()
        }

        return self
    }

    /// Разворачивает опциональное значение или возвращает заданное значение по умолчанию.
    /// Более удобный аналог оператора `??` для цепочек вызовов функций
    func or(_ defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
        self ?? defaultValue()
    }
}
