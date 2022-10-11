//
//  TokenProvider.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation

/// Объект, предоставляющий токен для подписи запроса в **Тинькофф Эквайринг API** на основе параметров,  отправляемых с body
public protocol ITokenProvider {
    /// Предоставление токена для подписи запроса
    ///
    /// Для генерации токена необходимо:
    /// * Добавить пароль от терминала в словарь с ключом `Password`,
    /// * Отсортировать пары ключ-значение по ключам в алфавитном порядке
    /// * Конкатенировать значения всех пар
    /// * Для полученной строки вычислить хэш SHA-256
    ///
    /// В простейшем случае реализация может выглядеть следующим образом:
    ///
    /// ```
    /// func provideToken(forRequestParameters parameters: [String: String], completion: @escaping (Result<String, Error>) -> Void) {
    ///    let sourceString = parameters
    ///        .merging(["Password": password]) { $1 }
    ///        .sorted { $0.key < $1.key }
    ///        .map(\.value)
    ///        .joined()
    ///
    ///    let hashingResult = Result {
    ///        try SHA256.hash(from: sourceString)
    ///    }
    ///
    ///    completion(hashingResult)
    /// }
    /// ```
    ///
    /// > Warning: Реализация выше приведена исключительно в качестве примера. В целях  безопасности не стоит хранить и как бы то ни было взаимодействовать
    /// с паролем от терминала в коде мобильного приложения.
    /// Наиболее подходящий сценарий - передавать полученные параметры на бекенд,
    /// где будет происходить генерация токена на основе параметров и пароля
    ///
    /// - Parameters:
    ///   - parameters: Словарь с параметрами, участвующими в формировании токена.
    ///   - completion: Замыкание, возвращающее результат формирования токена
    func provideToken(
        forRequestParameters parameters: [String: String],
        completion: @escaping (Result<String, Error>) -> Void
    )
}
