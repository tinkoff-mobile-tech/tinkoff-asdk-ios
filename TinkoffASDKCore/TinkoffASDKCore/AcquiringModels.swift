//
//  AcquiringModels.swift
//  TinkoffASDKCore
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

///
/// Cостояния платежа, подробнее [Двухстадийная форма оплаты](https://oplata.tinkoff.ru/landing/develop/documentation/processing_payment).
public enum PaymentStatus: String {
    /// Платёж создан
    case new = "NEW"

    /// Отмена платежа
    case cancelled = "CANCELLED"

    case preauthorizing = "PREAUTHORIZING"

    /// Покупатель перенаправлен на страницу оплаты
    case formshowed = "FORMSHOWED"

    /// Система начала обработку оплаты платежа
    case authorizing = "AUTHORIZING"

    /// Средства заблокированы, но не списаны
    case authorized = "AUTHORIZED"

    /// Покупатель начал аутентификацию по протоколу `3DSecure`. Статус может быть конечным, если клиент закрыл страницу ACS или не ввел код подтверждения 3Ds
    case checking3ds = "3DS_CHECKING"

    /// Покупатель завершил проверку 3DSecure
    case checked3ds = "3DS_CHECKED"

    /// Начало отмены блокировки средств
    case reversing = "REVERSING"

    /// Денежные средства разблокированы
    case reversed = "REVERSED"

    /// Начало списания денежных средств
    case confirming = "CONFIRMING"

    /// Денежные средства успешно списаны
    case confirmed = "CONFIRMED"

    /// Начало возврата денежных средств
    case refunding = "REFUNDING"

    /// Произведен возврат денежных средств
    case refunded = "REFUNDED"

    /// Произведен частичный возврат денежных средств
    case refundedPartial = "PARTIAL_REFUNDED"

    /// Ошибка платежа. Истекли попытки оплаты
    case rejected = "REJECTED"

    case completed = "COMPLETED"

    case hold = "HOLD"

    case hold3ds = "3DSHOLD"

    case loop = "LOOP_CHECKING"

    case unknown = "UNKNOWN"

    /// Ожидаем оплату по QR-коду
    case formShowed = "FORM_SHOWED"

    public init(rawValue: String) {
        switch rawValue {
        case "CANCELLED": self = .cancelled
        case "PREAUTHORIZING": self = .preauthorizing
        case "FORMSHOWED": self = .formshowed

        case "AUTHORIZING": self = .authorizing
        case "AUTHORIZED": self = .authorized

        case "3DS_CHECKING": self = .checking3ds
        case "3DS_CHECKED": self = .checked3ds

        case "REVERSING": self = .reversing
        case "REVERSED": self = .reversed

        case "CONFIRMING": self = .confirming
        case "CONFIRMED": self = .confirmed

        case "REFUNDING": self = .refunding
        case "REFUNDED": self = .refunded
        case "PARTIAL_REFUNDED": self = .refundedPartial

        case "REJECTED": self = .rejected

        case "COMPLETED": self = .completed

        case "HOLD": self = .hold
        case "3DSHOLD": self = .hold3ds
        case "LOOP_CHECKING": self = .loop

        case "NEW": self = .new
        case "UNKNOWN": self = .unknown

        case "FORM_SHOWED": self = .formShowed

        default: self = .unknown
        }
    }
}

public enum PaymentCardStatus: String {
    case active = "A"

    case inactive = "I"

    case deleted = "D"

    case unknown = "UNKNOWN"

    public init(rawValue: String) {
        switch rawValue {
        case "A": self = .active
        case "I": self = .inactive
        case "D": self = .deleted
        default: self = .unknown
        }
    }
}

public enum PaymentCardCheckType: String {
    case no = "NO"

    case check3DS = "3DS"

    case hold = "HOLD"

    case hold3DS = "3DSHOLD"

    public init(rawValue: String) {
        switch rawValue {
        case "3DS": self = .check3DS
        case "HOLD": self = .hold
        case "3DSHOLD": self = .hold3DS
        default: self = .no
        }
    }
}

// MARK: -

///
public struct PaymentCard: Codable {
    /// Название карты, по умолчанию выставяется замаскированный номер, например `430000******0777`
    public var pan: String

    public var cardId: String

    public var status: PaymentCardStatus

    /// Идентификатор родительского платежа
    /// Последний платеж с этой карты, который был  зарегистрирован как родительский платеж
    public var parentPaymentId: Int64?

    /// Срок годности карты в формате `MMYY`, например `1212`, для формата даты используем `expDateFormat`
    public var expDate: String?

    private enum CodingKeys: String, CodingKey {
        case pan = "Pan"
        case cardId = "CardId"
        case status = "Status"
        case parentPaymentId = "RebillId"
        case expDate = "ExpDate"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pan = try container.decode(String.self, forKey: .pan)
        cardId = try container.decode(String.self, forKey: .cardId)
        let statusRawValue = try container.decode(String.self, forKey: .status)
        status = PaymentCardStatus(rawValue: statusRawValue)

        if let stringValue = try? container.decode(String.self, forKey: .parentPaymentId), let value = Int64(stringValue) {
            self.parentPaymentId = value
        } else {
            self.parentPaymentId = try? container.decode(Int64.self, forKey: .parentPaymentId)
        }

        self.expDate = try? container.decode(String.self, forKey: .expDate)
    }

    public init(pan: String, cardId: String, status: PaymentCardStatus, parentPaymentId: Int64?, expDate: String?) {
        self.pan = pan
        self.cardId = cardId
        self.status = status
        self.parentPaymentId = parentPaymentId
        self.expDate = expDate
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pan, forKey: .pan)
        try container.encode(cardId, forKey: .cardId)
        try container.encode(status.rawValue, forKey: .status)
        if parentPaymentId != nil { try? container.encode(parentPaymentId, forKey: .parentPaymentId) }
        if expDate != nil { try? container.encode(expDate, forKey: .expDate) }
    }
}

public extension PaymentCard {
    func expDateFormat() -> String? {
        if let mm = expDate?.prefix(2), let yy = expDate?.suffix(2) {
            return "\(mm)/\(yy)"
        }

        return expDate
    }
}

// MARK: -

///
/// Тип проведения платежа - двухстадийная или одностадийная оплата.
public enum PayType: String {
    /// одностадийная оплата
    case oneStage = "O"

    /// двухстадийная оплата
    case twoStage = "T"

    public init(rawValue: String) {
        switch rawValue {
        case "O": self = .oneStage
        case "T": self = .twoStage
        default: self = .twoStage
        }
    }
}

// MARK: -

///
/// Тип оплаты
public enum PaymentMethod: String {
    /// Предоплата 100%
    /// Полная предварительная оплата до момента передачи предмета расчета
    case fullPrepayment = "full_prepayment"

    /// Предоплата
    /// Частичная предварительная оплата до момента передачи предмета расчета
    case prepayment

    /// Аванс
    case advance

    /// Полный расчет
    /// Полная оплата, в том числе с учетом аванса (предварительной оплаты) в момент передачи
    case fullPayment = "full_payment"

    /// Частичный расчет и кредит
    /// Частичная оплата предмета расчета в момент его передачи с последующей оплатой в кредит
    case partialPayment = "partial_payment"

    /// Передача в кредит
    /// Передача предмета расчета без его оплаты в момент его передачи с последующей оплатой в кредит
    case credit

    /// Оплата кредита
    /// Оплата предмета расчета после его передачи с оплатой в кредит
    case creditPayment = "credit_payment"

    public init(rawValue: String) {
        switch rawValue {
        case "full_prepayment": self = .fullPrepayment
        case "prepayment": self = .prepayment
        case "advance": self = .advance
        case "full_payment": self = .fullPayment
        case "partial_payment": self = .partialPayment
        case "credit": self = .credit
        case "credit_payment": self = .creditPayment
        default: self = .fullPrepayment
        } // switch rawValue
    } // init
}

// MARK: -

///
/// Ставка налога
public enum Tax: String {
    /// НДС по ставке 0%
    case vat0

    /// НДС чека по ставке 10%
    case vat10

    /// НДС чека по ставке 18%
    case vat18

    /// НДС чека по ставке 20%
    case vat20

    /// НДС чека по расчетной ставке 10/110
    case vat110

    /// НДС чека по расчетной ставке 18/118
    case vat118

    /// НДС чека по расчетной ставке 20/120
    case vat120

    /// Без НДС
    case none

    public init(rawValue: String) {
        switch rawValue {
        case "vat0": self = .vat0
        case "vat10": self = .vat10
        case "vat18": self = .vat18
        case "vat20": self = .vat20
        case "vat110": self = .vat110
        case "vat118": self = .vat118
        case "vat120": self = .vat20
        default: self = .none
        }
    }
}

// MARK: -

///
/// Система налогообложения.
public enum Taxation: String {
    /// Общая
    case osn

    /// Упрощенная (доходы)
    case usnIncome = "usn_income"

    /// Упрощенная (доходы минус расходы)
    case usnIncomeOutcome = "usn_income_outcome"

    /// Единый налог на вмененный доход
    case envd

    /// Единый сельскохозяйственный налог
    case esn

    /// Патентная
    case patent

    public init(rawValue: String) {
        switch rawValue {
        case "osn": self = .osn
        case "usn_income": self = .usnIncome
        case "usn_income_outcome": self = .usnIncomeOutcome
        case "envd": self = .envd
        case "esn": self = .esn
        case "patent": self = .patent
        default: self = .osn
        }
    }
}

// MARK: -

///
/// Признак предмета расчета
public enum PaymentObject: String {
    /// Подакцизный товар
    case excise

    /// Работа
    case job

    /// Услуга
    case service

    /// Ставка азартной игры
    case gamblingBet = "gambling_bet"

    /// Выигрыш азартной игры
    case gamblingPrize = "gambling_prize"

    /// Лотерейный билет
    case lottery

    /// Выигрыш лотереи
    case lotteryPrize = "lottery_prize"

    /// Предоставление результатов интеллектуальной деятельности
    case intellectualActivity = "intellectual_activity"

    /// Платеж
    case payment

    /// Агентское вознаграждение
    case agentCommission = "agent_commission"

    /// Составной предмет расчета
    case composite

    /// Иной предмет расчета
    case another

    public init(rawValue: String) {
        switch rawValue {
        case "excise": self = .excise
        case "job": self = .job
        case "service": self = .service
        case "gambling_bet": self = .gamblingBet
        case "gambling_prize": self = .gamblingPrize
        case "lottery": self = .lottery
        case "lottery_prize": self = .lotteryPrize
        case "intellectual_activity": self = .intellectualActivity
        case "payment": self = .payment
        case "agent_commission": self = .agentCommission
        case "composite": self = .composite
        default: self = .another
        } // switch rawValue
    } // init
}

// MARK: -

///
/// Признак агента
public enum AgentSign: String {
    /// Банковский платежный агент
    case bankPayingAgent = "bank_paying_agent"

    /// Банковский платежный субагент
    case bankPayingSubagent = "bank_paying_subagent"

    /// Платежный агент
    case payingAgent = "paying_agent"

    /// Платежный субагент
    case payingSubagent = "paying_subagent"

    /// Поверенный
    case attorney

    /// Комиссионер
    case commissionAgent = "commission_agent"

    /// Другой тип агента
    case another

    public init(rawValue: String) {
        switch rawValue {
        case "bank_paying_agent": self = .bankPayingAgent
        case "bank_paying_subagent": self = .bankPayingSubagent
        case "paying_agent": self = .payingAgent
        case "paying_subagent": self = .payingSubagent
        case "attorney": self = .attorney
        case "commission_agent": self = .commissionAgent
        default: self = .another
        }
    }
}

// MARK: -

///
/// Данные агента
public struct AgentData: Codable {
    /// Признак агента
    var agentSign: AgentSign

    /// Наименование операции. Строка длиной от 1 до 64 символов, необязательное поле
    /// - обязателен если `AgentSign` = `bankPayingAgent`
    /// - обязателен если `AgentSign` = `bankPayingSubagent`
    var operationName: String?

    /// Телефоны платежного агента. Массив строк длиной от 1 до 19 символов. Например ["+19221210697", "+19098561231"]
    /// - обязателен если `AgentSign` = `bankPayingAgent`
    /// - обязателен если `AgentSign` = `bankPayingSubagent`
    /// - обязателен если `AgentSign` = `payingAgent`
    /// - обязателен если `AgentSign` = `payingSubagent`
    var phones: [String]?

    /// Телефоны оператора по приему платежей. Массив строк длиной от 1 до 19 символов. Например ["+29221210697", "+29098561231"]
    /// - обязателен если `AgentSign` = `payingAgent`
    /// - обязателен если `AgentSign` = `payingSubagent`
    var receiverPhones: [String]?

    /// Телефоны оператора перевода. Массив строк длиной от 1 до 19 символов. Например ["+39221210697"]
    /// - обязателен если `AgentSign` = `bankPayingAgent`
    /// - обязателен если `AgentSign` = `bankPayingSubagent`
    var transferPhones: [String]?

    /// Наименование оператора перевода. Строка длиной от 1 до 64 символов.
    /// - обязателен если `AgentSign` = `bankPayingAgent`
    /// - обязателен если `AgentSign` = `bankPayingSubagent`
    var operatorName: String?

    /// Адрес оператора перевода. Строка длиной от 1 до 243 символов. Например "г. Ярославь, Волжская наб."
    /// - обязателен если `AgentSign` = `bankPayingAgent`
    /// - обязателен если `AgentSign` = `bankPayingSubagent`
    var operatorAddress: String?

    /// ИНН оператора перевода. Строка длиной от 10 до 12 символов.
    /// - обязателен если `AgentSign` = `bankPayingAgent`
    /// - обязателен если `AgentSign` = `bankPayingSubagent`
    var operatorInn: String?

    private enum CodingKeys: String, CodingKey {
        case agentSign = "AgentSign"
        case operationName = "OperationName"
        case phones = "Phones"
        case receiverPhones = "ReceiverPhones"
        case transferPhones = "TransferPhones"
        case operatorName = "OperatorName"
        case operatorAddress = "OperatorAddress"
        case operatorInn = "OperatorInn"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let agent = try? container.decode(String.self, forKey: .agentSign) {
            self.agentSign = AgentSign(rawValue: agent)
        } else {
            self.agentSign = .another
        }
        self.operationName = try? container.decode(String.self, forKey: .operationName)
        self.phones = try? container.decode([String].self, forKey: .phones)
        self.receiverPhones = try? container.decode([String].self, forKey: .receiverPhones)
        self.transferPhones = try? container.decode([String].self, forKey: .transferPhones)
        self.operatorName = try? container.decode(String.self, forKey: .operatorName)
        self.operatorAddress = try? container.decode(String.self, forKey: .operatorAddress)
        self.operatorInn = try? container.decode(String.self, forKey: .operatorInn)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(agentSign.rawValue, forKey: .agentSign)
        if operationName != nil { try? container.encode(operationName, forKey: .operationName) }
        if phones != nil { try? container.encode(phones, forKey: .phones) }
        if receiverPhones != nil { try? container.encode(receiverPhones, forKey: .receiverPhones) }
        if transferPhones != nil { try? container.encode(transferPhones, forKey: .transferPhones) }
        if operatorName != nil { try? container.encode(operatorName, forKey: .operatorName) }
        if operatorAddress != nil { try? container.encode(operatorAddress, forKey: .operatorAddress) }
        if operatorInn != nil { try? container.encode(operatorInn, forKey: .operatorInn) }
    }
}

// MARK: -

///
/// Данные поставщика платежного агента
public struct SupplierInfo: Codable {
    /// Телефон поставщика. Массив строк длиной от 1 до 19 символов. Например `["+19221210697", "+19098561231"]`
    var phones: [String]?

    /// Наименование поставщика. Строка до 239 символов.
    /// Внимание: в данные 243 символа включаются телефоны поставщика + 4 символа на каждый телефон.
    /// Например, если передано 2 телефона поставщика длиной 12 и 14 символов, то максимальная длина наименования поставщика будет 239 – (12 + 4) – (14 + 4)  = 205 символов
    var name: String?

    /// ИНН поставщика. Строка длиной от 10 до 12 символов.
    var inn: String?

    private enum CodingKeys: String, CodingKey {
        case phones = "Phones"
        case name = "Name"
        case inn = "Inn"
    }

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

// MARK: -

///
/// Информация о товаре
public struct Item: Codable {

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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        price = try container.decode(Int64.self, forKey: .price)
        quantity = try container.decode(Double.self, forKey: .quantity)
        name = try? container.decode(String.self, forKey: .name)
        amount = try container.decode(Int64.self, forKey: .amount)
        if let taxValue = try? container.decode(String.self, forKey: .tax) {
            self.tax = Tax(rawValue: taxValue)
        }
        self.ean13 = try? container.decode(String.self, forKey: .ean13)
        self.shopCode = try? container.decode(String.self, forKey: .shopCode)
        self.measurementUnit = try? container.decode(String.self, forKey: .measurementUnit)

        if let paymentMethodValue = try? container.decode(String.self, forKey: .paymentMethod) {
            self.paymentMethod = PaymentMethod(rawValue: paymentMethodValue)
        }
        if let paymentObjectValue = try? container.decode(String.self, forKey: .paymentObject) {
            self.paymentObject = PaymentObject(rawValue: paymentObjectValue)
        }
        self.agentData = try? container.decode(AgentData.self, forKey: .agentData)
        self.supplierInfo = try? container.decode(SupplierInfo.self, forKey: .supplierInfo)
    }

    public init(amount: Int64,
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
                agentData: AgentData? = nil) {
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
    public init(amount: NSDecimalNumber,
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
                agentData: AgentData? = nil) {
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

// MARK: -

///
/// Информация о магазине, маркетплейс
/// Примечания:
/// - 1. Если передается Receipt, то: Amount (из Init/Cancel/Confirm) = сумма всех Amount (из Shops) = сумма всех Amount (из Items).
/// - 2. Fee не может быть больше Amount.
/// - 3. В запросе Cancel хотя бы один ShopCode должен был уже быть на Confirm.При этом сумма всех Amount в рамках ShopCode на Cancel не должна быть больше суммы всех Amount в рамках ShopCode на Confirm.
/// - 4. Amount в Shops на Confirm должен быть равен или меньше Amount в Shops на Init.
public struct Shop: Codable {
    /// Код магазина. Для параметра необходимо использовать значение параметра `Submerchant_ID`, полученного при регистрации партнеров через xml.
    var shopCode: String?

    /// Наименование позиции
    var name: String?

    /// Сумма в копейках, которая относится к указанному в `ShopCode` партнеру
    var amount: Int64?

    /// Сумма комиссии в копейках, удерживаемая из возмещения Партнера в пользу Маркетплейса. Если не передано, используется комиссия, указанная при регистрации.
    var fee: String?

    private enum CodingKeys: String, CodingKey {
        case shopCode = "ShopCode"
        case name = "Name"
        case amount = "Amount"
        case fee = "Fee"
    }

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

// MARK: -

///
/// Информация о чеке
public class Receipt: Codable {
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

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopCode = try? container.decode(String.self, forKey: .shopCode)
        email = try? container.decode(String.self, forKey: .email)
        if let value = try? container.decode(String.self, forKey: .taxation) {
            self.taxation = Taxation(rawValue: value)
        }
        self.phone = try? container.decode(String.self, forKey: .phone)
        self.items = try? container.decode([Item].self, forKey: .items)
        self.agentData = try? container.decode(AgentData.self, forKey: .agentData)
        self.supplierInfo = try? container.decode(SupplierInfo.self, forKey: .supplierInfo)
        self.customer = try? container.decode(String.self, forKey: .customer)
        self.customerInn = try? container.decode(String.self, forKey: .customerInn)
    }

    public init(shopCode: String?,
                email: String?,
                taxation: Taxation?,
                phone: String?,
                items: [Item]?,
                agentData: AgentData?,
                supplierInfo: SupplierInfo?,
                customer: String?,
                customerInn: String?) {
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
