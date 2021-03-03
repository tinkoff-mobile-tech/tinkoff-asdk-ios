//
//  PaymentQRGenerateRequest.swift
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

/// Тип возвращаемых данных для генерации QR-кода
public enum PaymentInvoiceSBPSourceType: String, Codable {
    /// `IMAGE` – В ответе возвращается SVG изображение QR-кода
    case imageSVG = "IMAGE"

    /// `PAYLOAD` – В ответе возвращается url с параметрами  (по-умолчанию)
    case url = "PAYLOAD"

    public init(rawValue: String) {
        switch rawValue {
        case "IMAGE": self = .imageSVG
        default: self = .url
        }
    }
}

public struct PaymentInvoiceQRCodeData: Codable {
    ///
    /// Уникальный идентификатор транзакции в системе Банка
    var paymentId: Int64

    ///
    /// Тип возвращаемых данных
    var paymentInvoiceType: PaymentInvoiceSBPSourceType

    enum CodingKeys: String, CodingKey {
        case paymentId = "PaymentId"
        case paymentInvoiceType = "DataType"
    }

    public init(paymentId: Int64, paymentInvoiceType: PaymentInvoiceSBPSourceType = .url) {
        self.paymentId = paymentId
        self.paymentInvoiceType = paymentInvoiceType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentId = try container.decode(Int64.self, forKey: .paymentId)
        if let typeValue = try? container.decode(String.self, forKey: .paymentInvoiceType) {
            paymentInvoiceType = PaymentInvoiceSBPSourceType(rawValue: typeValue)
        } else {
            paymentInvoiceType = .url
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(paymentId, forKey: .paymentId)
        try container.encode(paymentInvoiceType.rawValue, forKey: .paymentInvoiceType)
    }
}

/// регистрирует QR и возвращает информацию о нем.
/// Должен быть вызван после вызова метода `Init`
public class PaymentInvoiceQRCodeRequest: RequestOperation, AcquiringRequestTokenParams {
    // MARK: RequestOperation

    public var name = "GetQr"

    public var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    ///
    /// отмечаем параметры которые участвуют в вычислении `token`
    public var tokenParamsKey: Set<String> = [PaymentInvoiceQRCodeData.CodingKeys.paymentId.rawValue,
                                              PaymentInvoiceQRCodeData.CodingKeys.paymentInvoiceType.rawValue]

    ///
    /// - Parameter data: `PaymentInvoiceQRCodeData`
    public init(data: PaymentInvoiceQRCodeData) {
        if let json = try? data.encode2JSONObject() {
            parameters = json
        }
    }
}

public struct PaymentInvoiceQRCodeResponse: ResponseOperation {
    // MARK: AcquiringResponseProtocol

    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?

    // MARK: PaymentInvoice

    public var orderId: String
    public var paymentId: Int64
    public var qrCodeData: String

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case success = "Success"
        case errorCode = "ErrorCode"
        case errorMessage = "Message"
        case errorDetails = "Details"
        case terminalKey = "TerminalKey"
        //
        case orderId = "OrderId"
        case paymentId = "PaymentId"
        case qrCodeData = "Data"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)

        // orderId
        orderId = try container.decode(String.self, forKey: .orderId)

        // paymentId
        if let stringValue = try? container.decode(String.self, forKey: .paymentId), let value = Int64(stringValue) {
            paymentId = value
        } else {
            paymentId = try container.decode(Int64.self, forKey: .paymentId)
        }

        qrCodeData = try container.decode(String.self, forKey: .qrCodeData)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        try container.encode(terminalKey, forKey: .terminalKey)
        //
        try container.encode(orderId, forKey: .orderId)
        try container.encode(paymentId, forKey: .paymentId)
        try container.encode(qrCodeData, forKey: .qrCodeData)
    }
} // PaymentInvoiceQRCodeResponse

///
/// При первом вызове регистрирует QR-код и возвращает информацию о нем. При последующих
/// вызовах вовзращает информацию о ранее сгенерированном QR-коде. Перерегистрация статического QR-кода
/// происходит только при смене расчетного счета. Не привязан к конкретному платежу, может
/// быть вызван в любое время без предварительного вызова `Init`.
public final class PaymentInvoiceQRCodeCollectorRequest: RequestOperation, AcquiringRequestTokenParams {
    // MARK: RequestOperation

    public var name = "GetStaticQr"

    public var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    ///
    /// отмечаем параметры которые участвуют в вычислении `token`
    public var tokenParamsKey: Set<String> = [PaymentInvoiceQRCodeData.CodingKeys.paymentInvoiceType.rawValue]

    ///
    /// - Parameter data: `PaymentInvoiceQRCodeResponseType`
    public init(data: PaymentInvoiceSBPSourceType) {
        parameters = [:]
        parameters?.updateValue(data.rawValue, forKey: PaymentInvoiceQRCodeData.CodingKeys.paymentInvoiceType.rawValue)
    }
}

/// Статический QR-код для приема платежей
public struct PaymentInvoiceQRCodeCollectorResponse: ResponseOperation {
    // MARK: AcquiringResponseProtocol

    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?

    // MARK: Invoice Collector

    public var qrCodeData: String

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case success = "Success"
        case errorCode = "ErrorCode"
        case errorMessage = "Message"
        case errorDetails = "Details"
        case terminalKey = "TerminalKey"
        //
        case qrCodeData = "Data"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)
        //
        qrCodeData = try container.decode(String.self, forKey: .qrCodeData)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        try container.encode(terminalKey, forKey: .terminalKey)
        //
        try container.encode(qrCodeData, forKey: .qrCodeData)
    }
} // PaymentInvoiceQRCodeCollectorResponse
