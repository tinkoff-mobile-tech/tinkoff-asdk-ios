//
//  TokenProvider.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 10.10.2022.
//

import Foundation

/// Объект, предоставляющий токен для подписи http-запроса на основе параметров,
/// отправляемых с http-body в [Тинькофф Эквайринг API](https://oplata.tinkoff.ru/landing/develop/)
public protocol ITokenProvider {
    /// Предоставление токена для подписи
    /// - Parameters:
    ///   - parameters: Словарь с параметрами, участвующими в формировании токена.
    ///   Может быть сериализован с помощью `JSONSerialization`
    ///   - completion: Замыкание, возвращающее результат формирования токена
    func provideToken(
        forRequestParameters parameters: [String: Any],
        completion: @escaping (Result<String, Error>) -> Void
    )
}
