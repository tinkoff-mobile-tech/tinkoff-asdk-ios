//
//  TextAndImageHeaderViewPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 29.05.2023.
//

import Foundation
import UIKit
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class TextAndImageHeaderViewPresenterTests: BaseTestCase {

    var sut: TextAndImageHeaderViewPresenter!

    // MARK: Mocks

    var viewMock: TextAndImageHeaderViewInputMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut(with: "")
    }

    override func tearDown() {
        viewMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_setupView() {
        // given
        let title = "Some title"
        setupSut(with: title)

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setTitleCallsCount, 1)
        XCTAssertEqual(viewMock.setTitleReceivedArguments, title)
        XCTAssertEqual(viewMock.setImageCallsCount, 1)
        XCTAssertEqual(viewMock.setImageReceivedArguments, nil)
    }

    func test_copy() {
        // given
        let title = "Some title"
        setupSut(with: title)

        // when
        let copyObject = sut.copy()

        // given
        XCTAssertEqual(sut, copyObject as? TextAndImageHeaderViewPresenter)
        XCTAssertTrue(sut !== (copyObject as? TextAndImageHeaderViewPresenter))
    }
}

// MARK: - Private methods

extension TextAndImageHeaderViewPresenterTests {
    private func setupSut(with title: String) {
        viewMock = TextAndImageHeaderViewInputMock()
        sut = TextAndImageHeaderViewPresenter(title: title, imageAsset: nil)
        sut.view = viewMock

        viewMock.fullReset()
    }
}
