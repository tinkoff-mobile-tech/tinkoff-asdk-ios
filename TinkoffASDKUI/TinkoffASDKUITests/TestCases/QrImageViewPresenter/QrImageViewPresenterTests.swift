//
//  QrImageViewPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 17.05.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class QrImageViewPresenterTests: BaseTestCase {

    var sut: QrImageViewPresenter!

    // MARK: Mocks

    var viewMock: QrImageViewInputMock!
    var presenterOutputMock: QrImageViewPresenterOutputMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut(with: .dynamicQr(""))
    }

    override func tearDown() {
        viewMock = nil
        presenterOutputMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: Tests

    func test_qrDidLoad() {
        // when
        sut.qrDidLoad()

        // then
        XCTAssertEqual(presenterOutputMock.qrDidLoadCallsCount, 1)
    }

    func test_setQrType_when_dynamicQr() {
        // given
        let stringData = "some data"
        let type: QrImageType = .dynamicQr(stringData)
        viewMock.setQrCodeUrlCallsCount = 0

        // when
        sut.set(qrType: type)

        // then
        XCTAssertEqual(viewMock.setQrCodeUrlCallsCount, 1)
        XCTAssertEqual(viewMock.setQrCodeUrlReceivedArguments, stringData)
    }

    func test_setQrType_when_staticQr() {
        // given
        let stringData = "some data"
        let type: QrImageType = .staticQr(stringData)
        viewMock.setQrCodeHTMLCallsCount = 0

        // when
        sut.set(qrType: type)

        // then
        XCTAssertEqual(viewMock.setQrCodeHTMLCallsCount, 1)
    }

    func test_when_qrType_nil() {
        // given
        setupSut(with: nil)
        viewMock = QrImageViewInputMock()

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setQrCodeUrlCallsCount, 0)
        XCTAssertEqual(viewMock.setQrCodeHTMLCallsCount, 0)
    }
}

// MARK: - Private methods

extension QrImageViewPresenterTests {
    private func setupSut(with type: QrImageType?) {
        viewMock = QrImageViewInputMock()
        presenterOutputMock = QrImageViewPresenterOutputMock()
        sut = QrImageViewPresenter(qrType: type, output: presenterOutputMock)
        sut.view = viewMock
    }
}
