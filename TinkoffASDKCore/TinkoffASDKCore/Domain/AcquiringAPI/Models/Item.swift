//
//  Item.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Информация о товаре
public struct Item: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case price = "Price"
        case quantity = "Quantity"
        case name = "Name"
        case amount = "Amount"
        case tax = "Tax"
        case ean13 = "Ean13"
        case shopCode = "ShopCode"
        case measurementUnit = "MeasurementUnit"
        case paymentMethod = "PaymentMethod"
        case paymentObject = "PaymentObject"
        case agentData = "AgentData"
        case supplierInfo = "SupplierInfo"
    }

    /// Сумма в копейках. Целочисленное значение не более 10 знаков.
    var price: Int64 = 0
    /// Количество/вес - целая часть не более 8 знаков, дробная часть не более 3 знаков.
    var quantity: Double = 0.0
    /// Наименование товара. Максимальная длина строки – 64 символова.
    var name: String?
    /// Сумма в копейках. Целочисленное значение не более 10 знаков.
    var amount: Int64
    /// Ставка налога
    var tax: Tax?
    /// Штрих-код.
    var ean13: String?
    /// Код магазина. Необходимо использовать значение параметра Submerchant_ID, полученного в ответ при регистрации магазинов через xml. Если xml не используется, передавать поле не нужно.
    var shopCode: String?
    /// Единицы измерения позиции чека
    var measurementUnit: String?
    /// Тип оплаты
    var paymentMethod: PaymentMethod?
    /// Признак предмета расчета
    var paymentObject: PaymentObject?
    /// Данные агента
    var agentData: AgentData?
    /// Данные поставщика платежного агента
    var supplierInfo: SupplierInfo?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        price = try container.decode(Int64.self, forKey: .price)
        quantity = try container.decode(Double.self, forKey: .quantity)
        name = try? container.decode(String.self, forKey: .name)
        amount = try container.decode(Int64.self, forKey: .amount)
        if let taxValue = try? container.decode(String.self, forKey: .tax) {
            tax = Tax(rawValue: taxValue)
        }
        ean13 = try? container.decode(String.self, forKey: .ean13)
        shopCode = try? container.decode(String.self, forKey: .shopCode)
        measurementUnit = try? container.decode(String.self, forKey: .measurementUnit)

        if let paymentMethodValue = try? container.decode(String.self, forKey: .paymentMethod) {
            paymentMethod = PaymentMethod(rawValue: paymentMethodValue)
        }
        if let paymentObjectValue = try? container.decode(String.self, forKey: .paymentObject) {
            paymentObject = PaymentObject(rawValue: paymentObjectValue)
        }
        agentData = try? container.decode(AgentData.self, forKey: .agentData)
        supplierInfo = try? container.decode(SupplierInfo.self, forKey: .supplierInfo)
    }

    public init(
        amount: Int64,
        price: Int64,
        name: String,
        tax: Tax,
        quantity: Double = 1,
        paymentObject: PaymentObject? = nil,
        paymentMethod: PaymentMethod? = nil,
        ean13: String? = nil,
        shopCode: String? = nil,
        measurementUnit: String? = nil,
        supplierInfo: SupplierInfo? = nil,
        agentData: AgentData? = nil
    ) {
        self.amount = amount
        self.price = price
        self.name = name
        self.tax = tax
        self.quantity = quantity
        self.paymentObject = paymentObject
        self.paymentMethod = paymentMethod
        self.ean13 = ean13
        self.shopCode = shopCode
        self.measurementUnit = measurementUnit
        self.supplierInfo = supplierInfo
        self.agentData = agentData
    }

    @available(*, deprecated, message: "Рекомендуется использовать метод, который принимает параметры amount и price в копейках (Int64).")
    public init(
        amount: NSDecimalNumber,
        price: NSDecimalNumber,
        name: String,
        tax: Tax,
        quantity: Double = 1,
        paymentObject: PaymentObject? = nil,
        paymentMethod: PaymentMethod? = nil,
        ean13: String? = nil,
        shopCode: String? = nil,
        measurementUnit: String? = nil,
        supplierInfo: SupplierInfo? = nil,
        agentData: AgentData? = nil
    ) {
        self.amount = Int64(amount.doubleValue * 100)
        self.price = Int64(price.doubleValue * 100)
        self.name = name
        self.tax = tax
        self.quantity = quantity
        self.paymentObject = paymentObject
        self.paymentMethod = paymentMethod
        self.ean13 = ean13
        self.shopCode = shopCode
        self.measurementUnit = measurementUnit
        self.supplierInfo = supplierInfo
        self.agentData = agentData
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(price, forKey: .price)
        try container.encode(amount, forKey: .amount)
        try container.encode(quantity, forKey: .quantity)
        if name != nil { try? container.encode(name, forKey: .name) }
        if tax != nil { try? container.encode(tax?.rawValue, forKey: .tax) }
        if ean13 != nil { try? container.encode(ean13, forKey: .ean13) }
        if shopCode != nil { try? container.encode(shopCode, forKey: .shopCode) }
        if paymentMethod != nil { try? container.encode(paymentMethod?.rawValue, forKey: .paymentMethod) }
        if paymentObject != nil { try? container.encode(paymentObject?.rawValue, forKey: .paymentObject) }
        if agentData != nil { try? container.encode(agentData, forKey: .agentData) }
        if supplierInfo != nil { try? container.encode(supplierInfo, forKey: .supplierInfo) }
    }
}
