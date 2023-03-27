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

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        presenterMock = CardListPresenterMock()
        sut = CardListViewController(
            configuration: CardListScreenConfiguration(useCase: .cardList),
            presenter: presenterMock
        )
    }

    override func tearDown() {
        presenterMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_hideLoadingSnackbar() {
        allureId(2397536, "Уменьшение списка карт при успешном удаление карты")
        // given
        let snackbarMock = SnackbarControllerMock()
        sut.snackBarViewController = snackbarMock
        // when
        sut.hideLoadingSnackbar()
        // then
        XCTAssertEqual(snackbarMock.hideSnackViewCallsCount, 1)
        XCTAssertEqual(snackbarMock.hideSnackViewCallArguments?.animated, true)
        XCTAssertEqual(presenterMock.viewDidHideRemovingCardSnackBarCallsCount, 1)
        XCTAssertTrue(sut.snackBarViewController == nil)
    }
}
