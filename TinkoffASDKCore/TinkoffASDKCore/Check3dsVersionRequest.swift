//
//  Check3dsVersionRequest.swift
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

public final class Check3dsVersionRequest: PaymentFinishRequest {
    override public var name: String {
        return "Check3dsVersion"
    }
}

public struct Checking3DSURLData {
    public var tdsServerTransID: String

    public var threeDSMethodURL: String

    public var notificationURL: String

    public init(tdsServerTransID: String, threeDSMethodURL: String, notificationURL: String) {
        self.tdsServerTransID = tdsServerTransID
        self.threeDSMethodURL = threeDSMethodURL
        self.notificationURL = notificationURL
    }
}

/// Проверка версии для прохождения 3DS
public struct Check3dsVersionResponse: ResponseOperation {
    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    //
    public var tdsServerTransID: String?
    public var threeDSMethodURL: String?
    public var version: String
    public let paymentSystem: String?

    private enum CodingKeys: String, CodingKey {
        case success = "Success"
        case errorCode = "ErrorCode"
        case errorMessage = "Message"
        case errorDetails = "Details"
        case terminalKey = "TerminalKey"
        //
        case tdsServerTransID = "TdsServerTransID"
        case threeDSMethodURL = "ThreeDSMethodURL"
        case version = "Version"
        case paymentSystem = "PaymentSystem"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)
        //
        tdsServerTransID = try? container.decode(String.self, forKey: .tdsServerTransID)
        threeDSMethodURL = try? container.decode(String.self, forKey: .threeDSMethodURL)
        version = try container.decode(String.self, forKey: .version)
        paymentSystem = try? container.decode(String.self, forKey: .paymentSystem)
    } // init

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        try? container.encode(terminalKey, forKey: .terminalKey)
        //
        try? container.encode(tdsServerTransID, forKey: .tdsServerTransID)
        try? container.encode(threeDSMethodURL, forKey: .threeDSMethodURL)
        try container.encode(version, forKey: .version)
        try container.encode(paymentSystem, forKey: .paymentSystem)
    } // encode
} // FinishResponse
