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

    func test_thatTinkoffPayButtonIsNotDisplayed_whenResponseIsError() throws {
        // given
        let errorStub = ErrorStub()
        terminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        terminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .failure(errorStub)

        // when
        var state: Swift.Error?
        sut.loadState(for: .full(paymentOptions: .fake())) { result in
            if case let .failure(error) = result {
                state = error
            }
        }

        // then
        let result = try XCTUnwrap(state as? ErrorStub)
        XCTAssertEqual(errorStub, result)
    }

    func test_thatSBPIsDisplayed_whenResponseContainsSbp() throws {
        // given
        let banks = [SBPBank.fake]
        terminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        terminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [.sbp])
        )
        sbpBanksService.loadBanksCompletionClosureInput = .success(banks)
        sbpBankAppChecker.bankAppsPreferredByMerchantReturnValue = banks

        // when
        var state: MainFormDataState?
        sut.loadState(for: .full(paymentOptions: .fake())) { result in
            if case let .success(data) = result {
                state = data
            }
        }

        // then
        let primary = try XCTUnwrap(state?.primaryPaymentMethod)
        let spbBanks = try XCTUnwrap(state?.sbpBanks)
        XCTAssertEqual(spbBanks, banks)
        XCTAssertEqual(primary, .sbp)
    }

    func test_thatSBPIsNotPrimary_whenBanksListIsEmpty() throws {
        // given
        let errorStub = ErrorStub()
        let banks = [SBPBank.fake]
        terminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        terminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [.sbp])
        )
        sbpBanksService.loadBanksCompletionClosureInput = .failure(errorStub)
        sbpBankAppChecker.bankAppsPreferredByMerchantReturnValue = banks

        // when
        var state: MainFormDataState?
        sut.loadState(for: .full(paymentOptions: .fake())) { result in
            if case let .success(data) = result {
                state = data
            }
        }

        // then
        let primary = try XCTUnwrap(state?.primaryPaymentMethod)
        let methods = try XCTUnwrap(state?.otherPaymentMethods)
        XCTAssertTrue(methods.contains(.sbp))
        XCTAssertEqual(primary, .card)
    }

    func test_thatCardIsPrimaryMethod_whenResponseContainsActiveCards() throws {
        // given
        let card = PaymentCard.fake()
        terminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        terminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [.sbp], addCardScheme: true)
        )
        cardControllers.getActiveCardsStub = { completion in completion(.success([card])) }

        // when
        var state: MainFormDataState?
        sut.loadState(for: .full(paymentOptions: .fake())) { result in
            if case let .success(data) = result {
                state = data
            }
        }

        // then
        let primary = try XCTUnwrap(state?.primaryPaymentMethod)
        let cards = try XCTUnwrap(state?.cards)
        XCTAssertTrue(cards.contains(card))
        XCTAssertEqual(primary, .card)
    }

    func test_thatCardIsNotPrimaryMethod_whenResponseDoesNotContainCards() throws {
        // given
        terminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        terminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [.sbp], addCardScheme: true)
        )
        cardControllers.getActiveCardsStub = { completion in completion(.failure(ErrorStub())) }

        // when
        var state: MainFormDataState?
        sut.loadState(for: .full(paymentOptions: .fake())) { result in
            if case let .success(data) = result {
                state = data
            }
        }

        // then
        XCTAssertNil(state?.primaryPaymentMethod)
    }

    func test_thatYandexPayIsNotDispayed() throws {
        // given
        terminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        terminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [.yandexPay(.fake())], addCardScheme: true)
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

    func test_thatTinkoffPayIsNotDisplayed_whenStateIsFinish() throws {
        // given
        terminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        terminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [.tinkoffPay(.fake())], addCardScheme: true)
        )

        // when
        var state: MainFormDataState?
        sut.loadState(for: .finish(paymentOptions: .fake())) { result in
            if case let .success(data) = result {
                state = data
            }
        }

        // then
        let methods = try XCTUnwrap(state?.otherPaymentMethods)
        XCTAssertTrue(methods.isEmpty)
    }
}
