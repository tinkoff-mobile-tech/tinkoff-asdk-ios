//
//  YandexPayMethodProviderTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 19.05.2023.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
@testable import TinkoffASDKYandexPay
import XCTest
import YandexPaySDK

final class YandexPayMethodProviderTests: BaseTestCase {

    var sut: YandexPayMethodProvider!

    // Mocks

    var acquiringTerminalServiceMock: AcquiringTerminalServiceMock!

    override func setUp() {
        acquiringTerminalServiceMock = AcquiringTerminalServiceMock()
        sut = YandexPayMethodProvider(terminalService: acquiringTerminalServiceMock)
        super.setUp()
    }

    override func tearDown() {
        acquiringTerminalServiceMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_provideMethod_yandexPay_and_more() throws {
        allureId(2358061, "Отображаем кнопку YP, если /v2/GetTerminalPayMethods вернул YandexPay и другие Paymethods")

        // given
        var yandexPayMethod: YandexPayMethod?
        acquiringTerminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        acquiringTerminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [.sbp, .yandexPay(.fake())])
        )

        // when
        sut.provideMethod { result in
            switch result {
            case let .success(payMethod):
                yandexPayMethod = payMethod
            case .failure:
                break
            }
        }

        // then
        XCTAssertNotNil(yandexPayMethod)
    }

    func test_provideMethod_just_yandexPay() throws {
        allureId(2358060, "Отображаем кнопку YP, если /v2/GetTerminalPayMethods вернул только YandexPay")

        // given
        var yandexPayMethod: YandexPayMethod?
        acquiringTerminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        acquiringTerminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(
            .fake(methods: [.yandexPay(.fake())])
        )

        // when
        sut.provideMethod { result in
            switch result {
            case let .success(payMethod):
                yandexPayMethod = payMethod
            case .failure:
                break
            }
        }

        // then
        XCTAssertNotNil(yandexPayMethod)
    }

    func test_provideMethod_empty_array() throws {
        allureId(2358059, "Не отображаем кнопку YP, если /v2/GetTerminalPayMethods не вернул YandexPay")
        // given
        var receivedError: Error?
        acquiringTerminalServiceMock.getTerminalPayMethodsReturnValue = CancellableMock()
        acquiringTerminalServiceMock.getTerminalPayMethodsCompletionClosureInput = .success(.fake(methods: []))

        // when
        sut.provideMethod { result in
            switch result {
            case let .success(payMethod):
                break
            case let .failure(error):
                receivedError = error
            }
        }

        // then
        switch receivedError as? YandexPayMethodProvider.Error {
        case .methodUnavailable: break
        default: XCTFail()
        }
    }
}
