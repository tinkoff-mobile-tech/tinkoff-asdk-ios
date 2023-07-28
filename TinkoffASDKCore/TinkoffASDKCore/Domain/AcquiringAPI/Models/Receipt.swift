//
//  Receipt.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Информация о чеке
public struct Receipt: Codable {
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

    public init(from decoder: Decoder) throws {
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

    /// Инициализиатор может пробросить ошибку в случае передачи невалидных полей
    ///
    /// НСПК требует как минимимум 1 валидное поле `phone` или `email` для формирования чека
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
    ) throws {
        // Проверка обязательных полей
        try Self.validateMandatoryFields(phone: phone, email: email)
        // Инициализация свойств
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

    static func validateMandatoryFields(phone: String?, email: String?) throws {
        if let email = email {
            let isEmailValid = EmailValidator.validate(email)
            if !isEmailValid {
                throw ASDKCoreError.invalidEmail
            }
        }

        let checkValidaty: (String?) -> Bool = { input in
            let input = input?.trimmingCharacters(in: [" "])
            return (input != nil && input?.isEmpty == false)
        }

        let result = checkValidaty(phone) || checkValidaty(email)
        if !result {
            throw ASDKCoreError.missingReceiptFields
        }
    }
}

extension Receipt: Equatable {
    public static func == (lhs: Receipt, rhs: Receipt) -> Bool {
        return
            lhs.shopCode == rhs.shopCode &&
            lhs.email == rhs.email &&
            lhs.phone == rhs.phone &&
            lhs.taxation == rhs.taxation &&
            lhs.items == rhs.items &&
            lhs.agentData == rhs.agentData &&
            lhs.supplierInfo == rhs.supplierInfo &&
            lhs.customer == rhs.customer &&
            lhs.customerInn == rhs.customerInn
    }
}
