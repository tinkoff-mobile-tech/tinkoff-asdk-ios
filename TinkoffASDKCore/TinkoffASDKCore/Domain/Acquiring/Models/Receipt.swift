//
//  Receipt.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Информация о чеке
public class Receipt: Codable {
    private enum CodingKeys: String, CodingKey {
        case shopCode = "ShopCode"
        case email = "Email"
        case taxation = "Taxation"
        case phone = "Phone"
        case items = "Items"
        case agentData = "AgentData"
        case supplierInfo = "SupplierInfo"
        case customer = "Customer"
        case customerInn = "CustomerInn"
    }

    /// Код магазина
    public var shopCode: String?
    /// Электронный адрес для отправки чека покупателю
    /// Параметр `email` или `phone` должен быть заполнен.
    public var email: String?
    /// Телефон покупателя
    /// Параметр `email` или `phone` должен быть заполнен.
    public var phone: String?
    /// Система налогообложения
    public var taxation: Taxation?
    /// Массив, содержащий в себе информацию о товарах
    public var items: [Item]?
    /// Данные агента
    public var agentData: AgentData?
    /// Данные поставщика платежного агента
    public var supplierInfo: SupplierInfo?
    /// Идентификатор покупателя
    public var customer: String?
    /// Инн покупателя. Если ИНН иностранного гражданина, необходимо указать 00000000000
    public var customerInn: String?

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopCode = try? container.decode(String.self, forKey: .shopCode)
        email = try? container.decode(String.self, forKey: .email)
        if let value = try? container.decode(String.self, forKey: .taxation) {
            taxation = Taxation(rawValue: value)
        }
        phone = try? container.decode(String.self, forKey: .phone)
        items = try? container.decode([Item].self, forKey: .items)
        agentData = try? container.decode(AgentData.self, forKey: .agentData)
        supplierInfo = try? container.decode(SupplierInfo.self, forKey: .supplierInfo)
        customer = try? container.decode(String.self, forKey: .customer)
        customerInn = try? container.decode(String.self, forKey: .customerInn)
    }

    public init(
        shopCode: String?,
        email: String?,
        taxation: Taxation?,
        phone: String?,
        items: [Item]?,
        agentData: AgentData?,
        supplierInfo: SupplierInfo?,
        customer: String?,
        customerInn: String?
    ) {
        self.shopCode = shopCode
        self.email = email
        self.taxation = taxation
        self.phone = phone
        self.items = items
        self.agentData = agentData
        self.supplierInfo = supplierInfo
        self.customer = customer
        self.customerInn = customerInn
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if shopCode != nil { try? container.encode(shopCode, forKey: .shopCode) }
        if taxation != nil { try? container.encode(taxation?.rawValue, forKey: .taxation) }
        if email != nil { try? container.encode(email, forKey: .email) }
        if phone != nil { try? container.encode(phone, forKey: .phone) }
        if items != nil { try? container.encode(items, forKey: .items) }
        if agentData != nil { try? container.encode(agentData, forKey: .agentData) }
        if supplierInfo != nil { try? container.encode(supplierInfo, forKey: .supplierInfo) }
        if customer != nil { try? container.encode(customer, forKey: .customer) }
        if customerInn != nil { try? container.encode(customerInn, forKey: .customerInn) }
    }
}
