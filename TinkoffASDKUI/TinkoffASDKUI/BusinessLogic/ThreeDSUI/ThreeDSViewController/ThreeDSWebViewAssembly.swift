//
//  ThreeDSWebViewAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 17.02.2023.
//

import Foundation
import TinkoffASDKCore
import UIKit

final class ThreeDSWebViewAssembly: IThreeDSWebViewAssembly {
    // MARK: Dependencies

    private let coreSDK: AcquiringSdk
    private let authChallengeService: IWebViewAuthChallengeService

    // MARK: Init

    init(coreSDK: AcquiringSdk, authChallengeService: IWebViewAuthChallengeService) {
        self.coreSDK = coreSDK
        self.authChallengeService = authChallengeService
    }

    // MARK: IThreeDSWebViewAssembly

    func threeDSWebViewController<Payload: Decodable>(
        urlRequest: URLRequest,
        resultHandler: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) -> UIViewController {
        ThreeDSViewController<Payload>(
            urlRequest: urlRequest,
            handler: coreSDK.threeDSWebViewSHandler(),
            authChallengeService: authChallengeService,
            onResultReceived: resultHandler
        )
    }

    func threeDSWebViewNavigationController<Payload: Decodable>(
        urlRequest: URLRequest,
        resultHandler: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) -> UINavigationController {
        let viewController = threeDSWebViewController(urlRequest: urlRequest, resultHandler: resultHandler)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overFullScreen
        return navigationController
    }
}
