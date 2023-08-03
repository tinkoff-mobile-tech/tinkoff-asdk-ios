//
//  ReceiptFdv1_2.swift
//  TinkoffASDKCore
//
//  Created by Никита Васильев on 02.08.2023.
//
// swiftlint:disable type_name

import Foundation

public struct ReceiptFdv1_2: Encodable, Equatable {

    public let base: ReceiptFdv1_05
    /// Версия ФФД.
    public let ffdVersion: FfdVersion = .version1_2
    /// Идентификатор покупателя
    public var customer: String?
    /// Инн покупателя. Если ИНН иностранного гражданина, необходимо указать 00000000000
    public var customerInn: String?

    private enum CodingKeys: String, CodingKey {
        case shopCode = "ShopCode"
        case items = "Items"
        case ffdVersion = "FfdVersion"
        case email = "Email"
        case phone = "Phone"
        case taxation = "Taxation"
        case agentData = "AgentData"
        case supplierInfo = "SupplierInfo"
        case customer = "Customer"
        case customerInn = "CustomerInn"
    }

    public init(base: ReceiptFdv1_05, customer: String?, customerInn: String?) {
        self.base = base
        self.customer = customer
        self.customerInn = customerInn
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(base.shopCode, forKey: .shopCode)
        try container.encodeIfPresent(base.email, forKey: .email)
        try container.encodeIfPresent(base.phone, forKey: .phone)
        try container.encodeIfPresent(base.agentData, forKey: .agentData)
        try container.encodeIfPresent(base.supplierInfo, forKey: .supplierInfo)
        try container.encodeIfPresent(customer, forKey: .customer)
        try container.encodeIfPresent(customerInn, forKey: .customerInn)
        try container.encode(ffdVersion, forKey: .ffdVersion)
        try container.encode(base.taxation.rawValue, forKey: .taxation)
        try container.encode(base.items, forKey: .items)
    }
}
