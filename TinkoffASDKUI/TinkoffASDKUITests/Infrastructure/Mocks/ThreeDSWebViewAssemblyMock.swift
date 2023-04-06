//
//  ThreeDSWebViewAssemblyMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class ThreeDSWebViewAssemblyMock<GenericPayload: Decodable>: IThreeDSWebViewAssembly {

    typealias Completion = (ThreeDSWebViewHandlingResult<GenericPayload>) -> Void

    // MARK: - threeDSWebViewController<Payload: Decodable>

    typealias ThreeDSWebViewControllerArguments = (urlRequest: URLRequest, completion: (ThreeDSWebViewHandlingResult<GenericPayload>) -> Void)

    var threeDSWebViewControllerCallsCount = 0
    var threeDSWebViewControllerReceivedArguments: ThreeDSWebViewControllerArguments?
    var threeDSWebViewControllerReceivedInvocations: [ThreeDSWebViewControllerArguments] = []
    var threeDSWebViewControllerReturnValue: UIViewController!

    func threeDSWebViewController<Payload: Decodable>(
        urlRequest: URLRequest,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) -> UIViewController {
        threeDSWebViewControllerCallsCount += 1
        let arguments = (urlRequest, completion as! Completion)
        threeDSWebViewControllerReceivedArguments = arguments
        threeDSWebViewControllerReceivedInvocations.append(arguments)
        return threeDSWebViewControllerReturnValue
    }

    // MARK: - threeDSWebViewNavigationController<Payload: Decodable>

    typealias ThreeDSWebViewNavigationControllerArguments = (urlRequest: URLRequest, completion: (ThreeDSWebViewHandlingResult<GenericPayload>) -> Void)

    var threeDSWebViewNavigationControllerCallsCount = 0
    var threeDSWebViewNavigationControllerReceivedArguments: ThreeDSWebViewNavigationControllerArguments?
    var threeDSWebViewNavigationControllerReceivedInvocations: [ThreeDSWebViewNavigationControllerArguments] = []
    var threeDSWebViewNavigationControllerReturnValue: UINavigationController!

    func threeDSWebViewNavigationController<Payload: Decodable>(
        urlRequest: URLRequest,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) -> UINavigationController {
        threeDSWebViewNavigationControllerCallsCount += 1
        let arguments = (urlRequest, completion as! Completion)
        threeDSWebViewNavigationControllerReceivedArguments = arguments
        threeDSWebViewNavigationControllerReceivedInvocations.append(arguments)
        return threeDSWebViewNavigationControllerReturnValue
    }
}
