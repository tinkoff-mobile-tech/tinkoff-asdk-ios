//
//  CardListViewControllerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 24.03.2023.
//

import XCTest

@testable import TinkoffASDKUI

final class CardListViewControllerTests: BaseTestCase {

    var sut: CardListViewController!

    // Mocks
    var presenterMock: CardListPresenterMock!
    var snackbarControllerMock: SnackbarControllerMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        presenterMock = CardListPresenterMock()
        snackbarControllerMock = SnackbarControllerMock()
        sut = CardListViewController(
            configuration: CardListScreenConfiguration(useCase: .cardList),
            presenter: presenterMock,
            snackBarViewController: snackbarControllerMock
        )
    }

    override func tearDown() {
        presenterMock = nil
        snackbarControllerMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_hideLoadingSnackbar() {
        allureId(2397536, "Уменьшение списка карт при успешном удаление карты")
        // when
        sut.hideLoadingSnackbar()
        // then
        XCTAssertEqual(snackbarControllerMock.hideSnackViewCallsCount, 1)
        XCTAssertEqual(snackbarControllerMock.hideSnackViewCallArguments?.animated, true)
        XCTAssertEqual(presenterMock.viewDidHideRemovingCardSnackBarCallsCount, 1)
    }
}
