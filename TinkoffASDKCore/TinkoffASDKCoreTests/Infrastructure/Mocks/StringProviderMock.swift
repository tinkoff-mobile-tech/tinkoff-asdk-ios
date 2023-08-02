//
//  StringProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 25.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class StringProviderMock: IStringProvider {

    var value: String {
        get { return underlyingValue }
        set(value) { underlyingValue = value }
    }

    var underlyingValue = "doesNotMatter"
}
