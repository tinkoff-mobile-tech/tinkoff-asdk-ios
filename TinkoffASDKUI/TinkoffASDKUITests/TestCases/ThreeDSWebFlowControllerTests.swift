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

    private typealias ThreeDSWebViewResult = ThreeDSWebViewHandlingResult<GetPaymentStatePayload>

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
        allureId(2358072) // ASDK совершил редирект на ACSurl для прохождения 3DS v1

        // given
        let data = Confirmation3DSData.fake()
        let navController = UINavigationController()
        let viewControllerMock = UIViewControllerMock()
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

        completion(.failed(TestsError.basic))

        // then
        let result = try XCTUnwrap(completionResult)
        guard case let ThreeDSWebViewResult.failed(error) = result, error is TestsError else {
            XCTFail()
            return
        }

        let requestUrlInWebView = threeDSWebViewAssemblyMock
            .threeDSWebViewNavigationControllerReceivedArguments?
            .urlRequest.url

        XCTAssertEqual(threeDSWebFlowDelegateMock.sourceViewControllerToPresentCallsCount, 1)
        XCTAssertEqual(threeDSServiceMock.createConfirmation3DSRequestCallCounter, 1)
        XCTAssertEqual(threeDSWebViewAssemblyMock.threeDSWebViewNavigationControllerCallsCount, 1)
        XCTAssertEqual(viewControllerMock.invokedPresentAnimatedCount, 1)
        XCTAssertTrue(viewControllerMock.invokedPresentAnimatedParameters?.viewControllerToPresent === navController)
        XCTAssertEqual(requestUrlInWebView?.absoluteString, data.acsUrl)
    }

    func test_confirm3DSACS() throws {
        allureId(2397494, "Инициалилизируем 3DS web-view v2 по ответу v2/AttachCard")

        // given
        let data = Confirmation3DSDataACS.fake()
        let navController = UINavigationController()
        let viewControllerMock = UIViewControllerMock()
        threeDSWebViewAssemblyMock.threeDSWebViewNavigationControllerReturnValue = navController
        threeDSWebFlowDelegateMock.sourceViewControllerToPresentReturnValue = viewControllerMock
        threeDSServiceMock.createConfirmation3DSRequestACSReturnStub = { args in
            URLRequest(url: URL(string: data.acsUrl) ?? .empty)
        }

        var completionResult: ThreeDSWebViewResult?
        let completion: (ThreeDSWebViewResult) -> Void = {
            completionResult = $0
        }

        // when
        sut.confirm3DSACS(
            data: data,
            messageVersion: "2.0",
            completion: completion
        )

        // tap back button in nav bar
        completion(.failed(TestsError.basic))

        // then
        let result = try XCTUnwrap(completionResult)
        guard case let ThreeDSWebViewResult.failed(error) = result, error is TestsError else {
            XCTFail()
            return
        }

        let requestUrlInWebView = threeDSWebViewAssemblyMock
            .threeDSWebViewNavigationControllerReceivedArguments?
            .urlRequest.url

        XCTAssertEqual(threeDSWebFlowDelegateMock.sourceViewControllerToPresentCallsCount, 1)
        XCTAssertEqual(threeDSServiceMock.createConfirmation3DSRequestACSCallCounter, 1)
        XCTAssertEqual(threeDSWebViewAssemblyMock.threeDSWebViewNavigationControllerCallsCount, 1)
        XCTAssertEqual(viewControllerMock.invokedPresentAnimatedCount, 1)
        XCTAssertTrue(viewControllerMock.invokedPresentAnimatedParameters?.viewControllerToPresent === navController)
        XCTAssertEqual(requestUrlInWebView?.absoluteString, data.acsUrl)
    }
}
