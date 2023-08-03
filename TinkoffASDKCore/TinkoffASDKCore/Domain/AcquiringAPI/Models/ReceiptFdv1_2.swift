//
//  ReceiptFdv1_2.swift
//  TinkoffASDKCore
//
//  Created by Никита Васильев on 02.08.2023.
//
// swiftlint:disable type_name

import Foundation

public struct ReceiptFdv1_2: Encodable {
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

    public let base: ReceiptFdv1_05
    public var customer: String?
    /// Инн покупателя. Если ИНН иностранного гражданина, необходимо указать 00000000000
    public var customerInn: String?
    /// Версия ФФД.
    public let ffdVersion: FfdVersion = .version1_2

    public init(base: ReceiptFdv1_05, customer: String?, customerInn: String?) {
        self.base = base
        self.customer = customer
        self.customerInn = customerInn
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if base.shopCode != nil { try? container.encode(base.shopCode, forKey: .shopCode) }
        if base.taxation != nil { try? container.encode(base.taxation?.rawValue, forKey: .taxation) }
        if base.email != nil { try? container.encode(base.email, forKey: .email) }
        if base.phone != nil { try? container.encode(base.phone, forKey: .phone) }
        if base.items != nil { try? container.encode(base.items, forKey: .items) }
        if base.agentData != nil { try? container.encode(base.agentData, forKey: .agentData) }
        if base.supplierInfo != nil { try? container.encode(base.supplierInfo, forKey: .supplierInfo) }
        if customer != nil { try? container.encode(customer, forKey: .customer) }
        if customerInn != nil { try? container.encode(customerInn, forKey: .customerInn) }
        try? container.encode(ffdVersion, forKey: .ffdVersion)
    }
}

extension ReceiptFdv1_2: Equatable {
    public static func == (lhs: ReceiptFdv1_2, rhs: ReceiptFdv1_2) -> Bool {
        lhs.base == rhs.base &&
            lhs.customer == rhs.customer &&
            lhs.customerInn == rhs.customerInn &&
            lhs.ffdVersion == rhs.ffdVersion
    }
}
