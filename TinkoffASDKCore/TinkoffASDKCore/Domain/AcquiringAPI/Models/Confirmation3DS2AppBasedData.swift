//
//  Confirmation3DS2AppBasedData.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

public struct Confirmation3DS2AppBasedData: Codable {
    private enum CodingKeys: CodingKey {
        case acsSignedContent
        case acsTransId
        case tdsServerTransId
        case acsRefNumber

        var stringValue: String {
            switch self {
            case .acsSignedContent: return APIConstants.Keys.acsSignedContent
            case .acsTransId: return APIConstants.Keys.acsTransId
            case .tdsServerTransId: return APIConstants.Keys.tdsServerTransId
            case .acsRefNumber: return APIConstants.Keys.acsRefNumber
            }
        }
    }

    public let acsSignedContent: String
    public let acsTransId: String
    public let tdsServerTransId: String
    public let acsRefNumber: String
}
