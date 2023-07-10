//
//  TimeoutResolverMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.04.2023.
//

@testable import TinkoffASDKUI

final class TimeoutResolverMock: ITimeoutResolver {

    var mapiValue: String {
        get {
            mapiValueGetCalls += 1
            return underlyingMapiValue
        }
        set(value) { underlyingMapiValue = value }
    }

    var mapiValueGetCalls: Int = 0
    lazy var underlyingMapiValue: String = "05"

    var challengeValue: Int {
        get {
            challengeValueGetCalls += 1
            return underlyingChallengeValue
        }
        set(value) { underlyingChallengeValue = value }
    }

    var challengeValueGetCalls: Int = 0
    var underlyingChallengeValue: Int = 5
}
