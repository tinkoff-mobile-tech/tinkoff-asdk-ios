//
//  SupplierInfo.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Данные поставщика платежного агента
public struct SupplierInfo: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case phones = "Phones"
        case name = "Name"
        case inn = "Inn"
    }

    /// Телефон поставщика. Массив строк длиной от 1 до 19 символов. Например `["+19221210697", "+19098561231"]`
    var phones: [String]?
    /// Наименование поставщика. Строка до 239 символов.
    /// Внимание: в данные 243 символа включаются телефоны поставщика + 4 символа на каждый телефон.
    /// Например, если передано 2 телефона поставщика длиной 12 и 14 символов, то максимальная длина наименования поставщика будет 239 – (12 + 4) – (14 + 4)  = 205 символов
    var name: String?
    /// ИНН поставщика. Строка длиной от 10 до 12 символов.
    var inn: String?

    // MARK: Init

    public init(
        phones: [String]? = nil,
        name: String? = nil,
        inn: String? = nil
    ) {
        self.phones = phones
        self.name = name
        self.inn = inn
    }

    // MARK: Init from decoder

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        phones = try? container.decode([String].self, forKey: .phones)
        name = try? container.decode(String.self, forKey: .name)
        inn = try? container.decode(String.self, forKey: .inn)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if phones != nil { try? container.encode(phones, forKey: .phones) }
        if name != nil { try? container.encode(name, forKey: .name) }
        if inn != nil { try? container.encode(inn, forKey: .inn) }
    }
}
