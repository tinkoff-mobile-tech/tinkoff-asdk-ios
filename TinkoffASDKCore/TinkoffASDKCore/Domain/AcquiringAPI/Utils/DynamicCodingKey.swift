//
//  DynamicCodingKey.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 01.08.2023.
//

import Foundation

public struct DynamicCodingKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.intValue = intValue
        stringValue = ""
    }
}
