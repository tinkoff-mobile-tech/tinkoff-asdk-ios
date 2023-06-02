//
//  MainFormDataStateLoaderTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 31.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class MainFormDataStateLoaderTests: BaseTestCase {

    /// Dependencies
    private var sut: MainFormDataStateLoader!
    private var terminalServiceMock: AcquiringTerminalServiceMock!
    private var cardControllers: CardsControllerMock!
    private var sbpBanksService: SBPBanksServiceMock!
    private var sbpBankAppChecker: SBPBankAppCheckerMock!
    private var tinkoffPayAppChecker: TinkoffPayAppCheckerMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        terminalServiceMock = AcquiringTerminalServiceMock()
        cardControllers = CardsControllerMock()
        sbpBanksService = SBPBanksServiceMock()
        sbpBankAppChecker = SBPBankAppCheckerMock()
        tinkoffPayAppChecker = TinkoffPayAppCheckerMock()
        sut = MainFormDataStateLoader(
            terminalService: terminalServiceMock,
            cardsController: cardControllers,
            sbpBanksService: sbpBanksService,
            sbpBankAppChecker: sbpBankAppChecker,
            tinkoffPayAppChecker: tinkoffPayAppChecker
        )
    }

    override func tearDown() {
        sut = nil
        terminalServiceMock = nil
        cardControllers = nil
        sbpBanksService = nil
        sbpBankAppChecker = nil
        tinkoffPayAppChecker = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatTinkoffPayButtonIsDisplayed_whenResponseContainsTPay() throws {
        allureId(2497797, "Кнопка отображается если getTerminalPayMethods вернул Tpay")

        // given
        let tpayPaymentMethod = TinkoffPayMethod.fake()
        terminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        terminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [.tinkoffPay(tpayPaymentMethod)])
        )

        // when
        var state: MainFormDataState?
        sut.loadState(for: .full(paymentOptions: .fake())) { result in
            if case let .success(data) = result {
                state = data
            }
        }

        // then
        let methods = try XCTUnwrap(state?.otherPaymentMethods)
        XCTAssertTrue(methods.contains(.tinkoffPay(tpayPaymentMethod)))
    }

    func test_thatTinkoffPayButtonIsNotDisplayed_whenResponseDoesNotContainTPay() throws {
        allureId(2497798, "Кнопка не отображается если GetTerminalPayMethods не вернул Tpay")

        // given
        terminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        terminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [])
        )

        // when
        var state: MainFormDataState?
        sut.loadState(for: .full(paymentOptions: .fake())) { result in
            if case let .success(data) = result {
                state = data
            }
        }

        // then
        let methods = try XCTUnwrap(state?.otherPaymentMethods)
        XCTAssertTrue(methods.isEmpty)
    }
}
