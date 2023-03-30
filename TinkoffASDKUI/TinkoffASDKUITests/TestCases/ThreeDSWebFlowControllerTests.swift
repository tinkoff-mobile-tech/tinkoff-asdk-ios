//
//  ThreeDSWebFlowController.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import XCTest

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class ThreeDSWebFlowControllerTests: BaseTestCase {

    var sut: ThreeDSWebFlowController!

    // Mocks

    var threeDSServiceMock: AcquiringThreeDsServiceMock!
    var threeDSWebViewAssemblyMock: ThreeDSWebViewAssemblyMock<GetPaymentStatePayload>!
    var threeDSWebFlowDelegateMock: ThreeDSWebFlowDelegateMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        threeDSServiceMock = AcquiringThreeDsServiceMock()
        threeDSWebViewAssemblyMock = ThreeDSWebViewAssemblyMock()
        threeDSWebFlowDelegateMock = ThreeDSWebFlowDelegateMock()

        sut = ThreeDSWebFlowController(
            threeDSService: threeDSServiceMock,
            threeDSWebViewAssembly: threeDSWebViewAssemblyMock
        )

        sut.webFlowDelegate = threeDSWebFlowDelegateMock
    }

    override func tearDown() {
        threeDSServiceMock = nil
        threeDSWebViewAssemblyMock = nil
        threeDSWebFlowDelegateMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_confirm3DS() throws {
        allureId(2397514, "Инициалилизируем 3DS web-view v1 по ответу v2/AttachCard")

        // given
        let data = Confirmation3DSData.fake()
        let navController = UINavigationController()
        let viewControllerMock = UIViewControllerMock()
        var shouldTapBackButtonInNavigationBar = true
        threeDSWebViewAssemblyMock.threeDSWebViewNavigationControllerReturnValue = navController
        threeDSWebFlowDelegateMock.sourceViewControllerToPresentReturnValue = viewControllerMock
        threeDSServiceMock.createConfirmation3DSRequestReturnStub = { args in
            URLRequest(url: URL(string: data.acsUrl) ?? .empty)
        }

        var completionResult: ThreeDSWebViewHandlingResult<GetPaymentStatePayload>?
        let completion: (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void = {
            completionResult = $0
        }

        // when
        sut.confirm3DS(
            data: data,
            completion: completion
        )

        if shouldTapBackButtonInNavigationBar {
            completion(.failed(TestsError.basic))
        }

        // then
        let result = try XCTUnwrap(completionResult)
        let requestUrlInWebView = threeDSWebViewAssemblyMock
            .threeDSWebViewNavigationControllerReceivedArguments?
            .urlRequest.url

        XCTAssertEqual(threeDSWebFlowDelegateMock.sourceViewControllerToPresentCallsCount, 1)
        XCTAssertEqual(threeDSServiceMock.createConfirmation3DSRequestCallCounter, 1)
        XCTAssertEqual(threeDSWebViewAssemblyMock.threeDSWebViewNavigationControllerCallsCount, 1)
        XCTAssertEqual(viewControllerMock.presentCallCount, 1)
        XCTAssertTrue(viewControllerMock.presentArguments?.viewControllerToPresent === navController)
        XCTAssertEqual(requestUrlInWebView?.absoluteString, data.acsUrl)
    }

    func test_confirm3DSACS() throws {
        allureId(2397494, "Инициалилизируем 3DS web-view v2 по ответу v2/AttachCard")

        // given
        let data = Confirmation3DSDataACS.fake()
        let navController = UINavigationController()
        let viewControllerMock = UIViewControllerMock()
        var shouldTapBackButtonInNavigationBar = true
        threeDSWebViewAssemblyMock.threeDSWebViewNavigationControllerReturnValue = navController
        threeDSWebFlowDelegateMock.sourceViewControllerToPresentReturnValue = viewControllerMock
        threeDSServiceMock.createConfirmation3DSRequestACSReturnStub = { args in
            URLRequest(url: URL(string: data.acsUrl) ?? .empty)
        }

        var completionResult: ThreeDSWebViewHandlingResult<GetPaymentStatePayload>?
        let completion: (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void = {
            completionResult = $0
        }

        // when
        sut.confirm3DSACS(
            data: data,
            messageVersion: "2.0",
            completion: completion
        )

        if shouldTapBackButtonInNavigationBar {
            completion(.failed(TestsError.basic))
        }

        // then
        let result = try XCTUnwrap(completionResult)
        let requestUrlInWebView = threeDSWebViewAssemblyMock
            .threeDSWebViewNavigationControllerReceivedArguments?
            .urlRequest.url

        XCTAssertEqual(threeDSWebFlowDelegateMock.sourceViewControllerToPresentCallsCount, 1)
        XCTAssertEqual(threeDSServiceMock.createConfirmation3DSRequestACSCallCounter, 1)
        XCTAssertEqual(threeDSWebViewAssemblyMock.threeDSWebViewNavigationControllerCallsCount, 1)
        XCTAssertEqual(viewControllerMock.presentCallCount, 1)
        XCTAssertTrue(viewControllerMock.presentArguments?.viewControllerToPresent === navController)
        XCTAssertEqual(requestUrlInWebView?.absoluteString, data.acsUrl)
    }
}
