//
//  TimeoutResolverMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.04.2023.
//

@testable import TinkoffASDKUI

final class TimeoutResolverMock: ITimeoutResolver {
    var mapiValue: String {
        get { return underlyingMapiValue }
        set(value) { underlyingMapiValue = value }
    }

    var underlyingMapiValue: String!
    var challengeValueGetCalls: Int = 0

    var challengeValue: Int {
        get {
            challengeValueGetCalls += 1
            return underlyingChallengeValue
        }
        set(value) { underlyingChallengeValue = value }
    }

    var underlyingChallengeValue: Int!
}
