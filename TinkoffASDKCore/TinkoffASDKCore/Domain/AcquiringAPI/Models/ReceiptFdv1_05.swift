//
//  ReceiptFdv1_05.swift
//  TinkoffASDKCore
//
//  Created by Никита Васильев on 02.08.2023.
//
// swiftlint:disable type_name

import Foundation

public struct ReceiptFdv1_05: Encodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case shopCode = "ShopCode"
        case items = "Items"
        case ffdVersion = "FfdVersion"
        case email = "Email"
        case phone = "Phone"
        case taxation = "Taxation"
        case agentData = "AgentData"
        case supplierInfo = "SupplierInfo"
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
    public var taxation: Taxation
    /// Массив, содержащий в себе информацию о товарах
    public var items: [Item]
    /// Данные агента
    public var agentData: AgentData?
    /// Данные поставщика платежного агента
    public var supplierInfo: SupplierInfo?
    /// Версия ФФД.
    public let ffdVersion: FfdVersion = .version1_05

    public init(
        shopCode: String?,
        email: String?,
        taxation: Taxation,
        phone: String?,
        items: [Item],
        agentData: AgentData?,
        supplierInfo: SupplierInfo?
    ) {
        self.shopCode = shopCode
        self.email = email
        self.taxation = taxation
        self.phone = phone
        self.items = items
        self.agentData = agentData
        self.supplierInfo = supplierInfo
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(shopCode, forKey: .shopCode)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(agentData, forKey: .agentData)
        try container.encodeIfPresent(supplierInfo, forKey: .supplierInfo)
        try container.encode(ffdVersion, forKey: .ffdVersion)
        try container.encode(taxation.rawValue, forKey: .taxation)
        try container.encode(items, forKey: .items)
    }
}
