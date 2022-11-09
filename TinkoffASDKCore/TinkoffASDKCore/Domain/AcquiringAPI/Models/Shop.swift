//
//  Shop.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Информация о магазине, маркетплейс
/// Примечания:
/// - 1. Если передается Receipt, то: Amount (из Init/Cancel/Confirm) = сумма всех Amount (из Shops) = сумма всех Amount (из Items).
/// - 2. Fee не может быть больше Amount.
/// - 3. В запросе Cancel хотя бы один ShopCode должен был уже быть на Confirm.При этом сумма всех Amount в рамках ShopCode на Cancel не должна быть больше суммы всех Amount в рамках ShopCode на Confirm.
/// - 4. Amount в Shops на Confirm должен быть равен или меньше Amount в Shops на Init.
public struct Shop: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case shopCode = "ShopCode"
        case name = "Name"
        case amount = "Amount"
        case fee = "Fee"
    }

    /// Код магазина. Для параметра необходимо использовать значение параметра `Submerchant_ID`, полученного при регистрации партнеров через xml.
    var shopCode: String?
    /// Наименование позиции
    var name: String?
    /// Сумма в копейках, которая относится к указанному в `ShopCode` партнеру
    var amount: Int64?
    /// Сумма комиссии в копейках, удерживаемая из возмещения Партнера в пользу Маркетплейса. Если не передано, используется комиссия, указанная при регистрации.
    var fee: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopCode = try? container.decode(String.self, forKey: .shopCode)
        name = try? container.decode(String.self, forKey: .name)
        amount = try? container.decode(Int64.self, forKey: .amount)
        fee = try? container.decode(String.self, forKey: .fee)
    }

    public init(shopCode: String?, name: String?, amount: Int64?, fee: String?) {
        self.shopCode = shopCode
        self.name = name
        self.amount = amount
        self.fee = fee
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if shopCode != nil { try? container.encode(shopCode, forKey: .shopCode) }
        if name != nil { try? container.encode(name, forKey: .name) }
        if amount != nil { try? container.encode(amount, forKey: .amount) }
        if fee != nil { try? container.encode(fee, forKey: .fee) }
    }
}
