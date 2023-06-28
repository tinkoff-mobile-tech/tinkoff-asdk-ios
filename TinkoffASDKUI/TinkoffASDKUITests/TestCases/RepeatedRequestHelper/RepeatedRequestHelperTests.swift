//
//  RepeatedRequestHelperTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 28.06.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class RepeatedRequestHelperTests: BaseTestCase {

    var sut: RepeatedRequestHelper!

    // MARK: Mocks

    var timerProviderMock: TimerProviderMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        timerProviderMock = TimerProviderMock()
        sut = RepeatedRequestHelper(timerProvider: timerProviderMock)
    }

    override func tearDown() {
        timerProviderMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_executeWithWaitingIfNeeded_oneCall() {
        // given
        var actionsCallsCount = 0
        let action = {
            actionsCallsCount += 1
        }

        timerProviderMock.executeTimerActionShouldCalls = true

        // when
        sut.executeWithWaitingIfNeeded(action: action)

        // then
        XCTAssertEqual(timerProviderMock.invalidateTimerCallsCount, 1)
        XCTAssertEqual(timerProviderMock.executeTimerCallsCount, 0)
        XCTAssertEqual(actionsCallsCount, 1)
    }

    func test_executeWithWaitingIfNeeded_twoCalls() {
        // given
        var actionsCallsCount = 0
        let action = {
            actionsCallsCount += 1
        }

        timerProviderMock.executeTimerActionShouldCalls = true

        // when
        sut.executeWithWaitingIfNeeded(action: action)
        sut.executeWithWaitingIfNeeded(action: action)

        // then
        XCTAssertEqual(timerProviderMock.invalidateTimerCallsCount, 2)
        XCTAssertEqual(timerProviderMock.executeTimerCallsCount, 1)
        XCTAssertEqual(actionsCallsCount, 2)
    }
}
