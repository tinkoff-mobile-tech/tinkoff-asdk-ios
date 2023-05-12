//
//  LogType.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 22.03.2023.
//

enum LogType {
    case request
    case response
    case networkError
    case common

    var logStartName: String {
        switch self {
        case .request: return "OUTGOING REQUEST"
        case .response: return "INCOMMING RESPONSE"
        case .networkError: return "NETWORK ERROR"
        case .common: return "LOGGING"
        }
    }

    var logFinishName: String {
        switch self {
        case .request: return "END OUTGOING REQUEST"
        case .response: return "END INCOMMING RESPONSE"
        case .networkError: return "END NETWORK ERROR"
        case .common: return "END LOGGING"
        }
    }
}
