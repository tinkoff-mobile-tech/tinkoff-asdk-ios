//
//  SafeDecodable.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 29.11.2022.
//

import Foundation

/// Обертка, позволяющая безопасно декодировать заданный тип
struct SafeDecodable<DecodableType: Decodable>: Decodable {
    /// Результат декодирования
    let decodingResult: Result<DecodableType, Error>

    init(from decoder: Decoder) throws {
        decodingResult = Result { try DecodableType(from: decoder) }
    }
}

extension SafeDecodable {
    /// В случае успешного декодирования возвращает объект, иначе - nil
    var decodedValue: DecodableType? {
        try? decodingResult.get()
    }
}
