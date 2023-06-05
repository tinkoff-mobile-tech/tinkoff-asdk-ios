//
//  RecurrentPaymentPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 05.06.2023.
//

import XCTest

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class RecurrentPaymentPresenterTests: BaseTestCase {

    var sut: RecurrentPaymentPresenter!

    // Mocksx`

    var viewMock: RecurrentPaymentViewInputMock!
    var savedCardViewPresenterAssemblyMock: SavedCardViewPresenterAssemblyMock!
    var payButtonViewPresenterAssemblyMock: PayButtonViewPresenterAssemblyMock!
    var paymentControllerMock: PaymentControllerMock!
    var cardsControllerMock: CardsControllerMock!
    var failureDelegateMock: RecurrentPaymentFailiureDelegateMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        savedCardViewPresenterAssemblyMock = nil
        payButtonViewPresenterAssemblyMock = nil
        paymentControllerMock = nil
        cardsControllerMock = nil
        failureDelegateMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad() {
        // given
        let paymentFlow = PaymentFlow.fake()
        let rebillId = "123456"
        let paymentSource = PaymentSourceData.parentPayment(rebuidId: rebillId)

        setupSut(paymentFlow: paymentFlow, rebillId: rebillId)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state.status, .processing)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.animatePullableContainerUpdates, false)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentSource, paymentSource)
    }

    func test_viewWasClosed() {
        // given
        var expectedPaymentResult: PaymentResult?
        let moduleCompletion: PaymentResultCompletion = { result in
            expectedPaymentResult = result
        }
        setupSut(moduleCompletion: moduleCompletion)

        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(expectedPaymentResult, .cancelled())
    }

//    func numberOfRows() -> Int {
//        cellTypes.count
//    }
//
//    func cellType(at indexPath: IndexPath) -> RecurrentPaymentCellType {
//        cellTypes[indexPath.row]
//    }

    func test_commonSheetViewDidTapPrimaryButton() {
        // when
        sut.commonSheetViewDidTapPrimaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 1)
    }
}

// MARK: - Private methods

extension RecurrentPaymentPresenterTests {
    private func setupSut(
        paymentFlow: PaymentFlow = .fake(),
        rebillId: String = "123456",
        amount: Int64 = 100,
        moduleCompletion: PaymentResultCompletion? = nil
    ) {
        viewMock = RecurrentPaymentViewInputMock()
        savedCardViewPresenterAssemblyMock = SavedCardViewPresenterAssemblyMock()
        payButtonViewPresenterAssemblyMock = PayButtonViewPresenterAssemblyMock()
        paymentControllerMock = PaymentControllerMock()
        cardsControllerMock = CardsControllerMock()
        failureDelegateMock = RecurrentPaymentFailiureDelegateMock()

        sut = RecurrentPaymentPresenter(
            savedCardViewPresenterAssembly: savedCardViewPresenterAssemblyMock,
            payButtonViewPresenterAssembly: payButtonViewPresenterAssemblyMock,
            paymentController: paymentControllerMock,
            cardsController: cardsControllerMock,
            paymentFlow: paymentFlow,
            rebillId: rebillId,
            amount: amount,
            failureDelegate: failureDelegateMock,
            moduleCompletion: moduleCompletion
        )
        sut.view = viewMock
    }
}
