//
//  AgentData.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Данные агента
public struct AgentData: Codable, Equatable {
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

    // MARK: - Init

    public init(
        agentSign: AgentSign,
        operationName: String? = nil,
        phones: [String]? = nil,
        receiverPhones: [String]? = nil,
        transferPhones: [String]? = nil,
        operatorName: String? = nil,
        operatorAddress: String? = nil,
        operatorInn: String? = nil
    ) {
        self.agentSign = agentSign
        self.operationName = operationName
        self.phones = phones
        self.receiverPhones = receiverPhones
        self.transferPhones = transferPhones
        self.operatorName = operatorName
        self.operatorAddress = operatorAddress
        self.operatorInn = operatorInn
    }

    // MARK: - Init from decoder

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let agent = try? container.decode(String.self, forKey: .agentSign) {
            agentSign = AgentSign(rawValue: agent)
        } else {
            agentSign = .another
        }
        operationName = try? container.decode(String.self, forKey: .operationName)
        phones = try? container.decode([String].self, forKey: .phones)
        receiverPhones = try? container.decode([String].self, forKey: .receiverPhones)
        transferPhones = try? container.decode([String].self, forKey: .transferPhones)
        operatorName = try? container.decode(String.self, forKey: .operatorName)
        operatorAddress = try? container.decode(String.self, forKey: .operatorAddress)
        operatorInn = try? container.decode(String.self, forKey: .operatorInn)
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
