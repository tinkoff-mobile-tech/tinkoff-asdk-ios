//
//  GetTinkoffPayStatusResponse.swift
//  TinkoffASDKCore
//
//  Created by Serebryaniy Grigoriy on 12.04.2022.
//

import Foundation

public struct GetTinkoffPayStatusResponse {
    public enum Status: Codable {
        public enum Version: String, Codable {
            case version1 = "1.0"
            case version2 = "2.0"
        }
        
        case disallowed
        case allowed(version: Version)
        
        private enum CodingKeys: String, CodingKey {
            case isAllowed = "Allowed"
            case version = "Version"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let isAllowed = try container.decode(Bool.self, forKey: .isAllowed)
            if isAllowed {
                let version = try container.decode(Version.self, forKey: .version)
                self = .allowed(version: version)
            } else {
                self = .disallowed
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .allowed(version):
                try container.encode(true, forKey: .isAllowed)
                try container.encode(version, forKey: .version)
            case .disallowed:
                try container.encode(false, forKey: .isAllowed)
            }
        }
    }
    
    public let success: Bool
    public let errorCode: Int
    public let errorMessage: String?
    public let errorDetails: String?
    public let status: Status
    public let terminalKey: String? = nil
}
extension GetTinkoffPayStatusResponse: ResponseOperation {
    private enum CodingKeys: String, CodingKey {
        case success = "Success"
        case errorCode = "ErrorCode"
        case errorMessage = "Message"
        case errorDetails = "Details"
        case params = "Params"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        status = try container.decode(Status.self, forKey: .params)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        try container.encode(status, forKey: .params)
    }
}
