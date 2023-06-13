//
//  MainFormPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

import XCTest

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MainFormPresenterTests: BaseTestCase {

    var sut: MainFormPresenter!

    // MARK: Mocks

    var viewMock: MainFormViewControllerMock!
    var routerMock: MainFormRouterMock!
    var mainFormOrderDetailsViewPresenterAssemblyMock: MainFormOrderDetailsViewPresenterAssemblyMock!
    var savedCardViewPresenterAssemblyMock: SavedCardViewPresenterAssemblyMock!
    var switchViewPresenterAssemblyMock: SwitchViewPresenterAssemblyMock!
    var emailViewPresenterAssemblyMock: EmailViewPresenterAssemblyMock!
    var payButtonViewPresenterAssemblyMock: PayButtonViewPresenterAssemblyMock!
    var textAndImageHeaderViewPresenterAssemblyMock: TextAndImageHeaderViewPresenterAssemblyMock!
    var dataStateLoaderMock: MainFormDataStateLoaderMock!
    var paymentControllerMock: PaymentControllerMock!
    var tinkoffPayControllerMock: TinkoffPayControllerMock!
    var cardScannerDelegateMock: CardScannerDelegateMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        routerMock = nil
        mainFormOrderDetailsViewPresenterAssemblyMock = nil
        savedCardViewPresenterAssemblyMock = nil
        switchViewPresenterAssemblyMock = nil
        emailViewPresenterAssemblyMock = nil
        payButtonViewPresenterAssemblyMock = nil
        textAndImageHeaderViewPresenterAssemblyMock = nil
        dataStateLoaderMock = nil
        paymentControllerMock = nil
        tinkoffPayControllerMock = nil
        cardScannerDelegateMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad() {
        XCTAssertTrue(true)
    }
}

// MARK: - Private methods

extension MainFormPresenterTests {
    private func setupSut(
        cardScannerDelegate: CardScannerDelegateMock? = CardScannerDelegateMock(),
        paymentFlow: PaymentFlow = .fake(),
        configuration: MainFormUIConfiguration = MainFormUIConfiguration(orderDescription: "some text"),
        moduleCompletion: PaymentResultCompletion? = nil
    ) {
        routerMock = MainFormRouterMock()
        mainFormOrderDetailsViewPresenterAssemblyMock = MainFormOrderDetailsViewPresenterAssemblyMock()
        savedCardViewPresenterAssemblyMock = SavedCardViewPresenterAssemblyMock()
        switchViewPresenterAssemblyMock = SwitchViewPresenterAssemblyMock()
        emailViewPresenterAssemblyMock = EmailViewPresenterAssemblyMock()
        payButtonViewPresenterAssemblyMock = PayButtonViewPresenterAssemblyMock()
        textAndImageHeaderViewPresenterAssemblyMock = TextAndImageHeaderViewPresenterAssemblyMock()
        dataStateLoaderMock = MainFormDataStateLoaderMock()
        paymentControllerMock = PaymentControllerMock()
        tinkoffPayControllerMock = TinkoffPayControllerMock()
        cardScannerDelegateMock = cardScannerDelegate

        sut = MainFormPresenter(
            router: routerMock,
            mainFormOrderDetailsViewPresenterAssembly: mainFormOrderDetailsViewPresenterAssemblyMock,
            savedCardViewPresenterAssembly: savedCardViewPresenterAssemblyMock,
            switchViewPresenterAssembly: switchViewPresenterAssemblyMock,
            emailViewPresenterAssembly: emailViewPresenterAssemblyMock,
            payButtonViewPresenterAssembly: payButtonViewPresenterAssemblyMock,
            textAndImageHeaderViewPresenterAssembly: textAndImageHeaderViewPresenterAssemblyMock,
            dataStateLoader: dataStateLoaderMock,
            paymentController: paymentControllerMock,
            tinkoffPayController: tinkoffPayControllerMock,
            paymentFlow: paymentFlow,
            configuration: configuration,
            cardScannerDelegate: cardScannerDelegateMock,
            moduleCompletion: moduleCompletion
        )

        sut.view = viewMock
    }
}
