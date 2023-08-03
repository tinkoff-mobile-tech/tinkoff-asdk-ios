//
//  Receipt.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//
// swiftlint:disable identifier_name

import Foundation

public enum Receipt: Equatable, Encodable {
    case version1_05(ReceiptFdv1_05)
    case version1_2(ReceiptFdv1_2)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .version1_05(info):
            try container.encode(info)
        case let .version1_2(info):
            try container.encode(info)
        }
    }
}
