//
//
//  GetConfigResponse.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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

public struct GetConfigResponse: Decodable {
    public let certificates: [CertificateData]
    
    private enum CodingKeys: String, CodingKey {
        case certificates = "certificatesInfo"
    }
}

public struct CertificateData: Decodable {
    public let paymentSystem: String
    public let directoryServerID: String
    public let type: String
    public let url: String
    public let notAfterDate: String
    public let sha256Fingerprint: String
    public let algorithm: String
    public let forceUpdateFlag: Bool
    
    private enum CodingKeys: String, CodingKey {
        case paymentSystem
        case directoryServerID
        case type
        case url
        case notAfterDate
        case sha256Fingerprint = "SHA256Fingerprint"
        case algorithm
        case forceUpdateFlag
    }
}
