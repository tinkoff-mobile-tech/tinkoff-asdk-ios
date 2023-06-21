//
//  SwitchViewPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

import Foundation
import UIKit
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SwitchViewPresenterTests: BaseTestCase {

    var sut: SwitchViewPresenter!

    // MARK: Mocks

    var viewMock: SwitchViewInputMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_switchButtonValueChanged_to_newValue() {
        // given
        var isValueOn: Bool?
        var isActionCalled = false
        let action = { isOn in
            isValueOn = isOn
            isActionCalled = true
        }

        setupSut(actionBlock: action)

        // when
        sut.switchButtonValueChanged(to: false)

        // then
        XCTAssertEqual(isValueOn, false)
        XCTAssertTrue(isActionCalled)
    }

    func test_switchButtonValueChanged_to_oldValue() {
        // given
        var isValueOn: Bool?
        var isActionCalled = false
        let action = { isOn in
            isValueOn = isOn
            isActionCalled = true
        }

        setupSut(actionBlock: action)

        // when
        sut.switchButtonValueChanged(to: true)

        // then
        XCTAssertEqual(isValueOn, nil)
        XCTAssertFalse(isActionCalled)
    }

    func test_setupView() {
        // given
        let title = "Some title"
        let isOn = false
        setupSut(title: title, isOn: isOn)

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setNameLabelCallsCount, 1)
        XCTAssertEqual(viewMock.setNameLabelReceivedArguments, title)
        XCTAssertEqual(viewMock.setSwitchButtonStateCallsCount, 1)
        XCTAssertEqual(viewMock.setSwitchButtonStateReceivedArguments, isOn)
    }
}

// MARK: - Private methods

extension SwitchViewPresenterTests {
    private func setupSut(title: String = "", isOn: Bool = true, actionBlock: SwitchViewPresenterActionBlock? = nil) {
        viewMock = SwitchViewInputMock()
        sut = SwitchViewPresenter(title: title, isOn: isOn, actionBlock: actionBlock)
        sut.view = viewMock

        viewMock.fullReset()
    }
}
