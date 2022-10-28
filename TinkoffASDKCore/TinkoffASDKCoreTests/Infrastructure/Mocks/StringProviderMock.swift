//
//  StringProviderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 25.10.2022.
//

import Foundation
@testable import TinkoffASDKCore

final class StringProviderMock: IStringProvider {
    var invokedValueGetter = false
    var invokedValueGetterCount = 0
    var stubbedValue: String = "doesNotMatter"

    var value: String {
        invokedValueGetter = true
        invokedValueGetterCount += 1
        return stubbedValue
    }
}
