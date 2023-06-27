//
//  ThreeDSWebFlowController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 17.02.2023.
//

import Foundation
import TinkoffASDKCore
import UIKit

final class ThreeDSWebFlowController: IThreeDSWebFlowController {
    // MARK: Error

    enum Error: Swift.Error {
        case missingWebFlowDelegate
        case missingSourceViewController
    }

    // MARK: Dependencies

    weak var webFlowDelegate: (any ThreeDSWebFlowDelegate)?
    private let threeDSService: IAcquiringThreeDSService
    private let threeDSWebViewAssembly: IThreeDSWebViewAssembly

    // MARK: Init

    init(
        threeDSService: IAcquiringThreeDSService,
        threeDSWebViewAssembly: IThreeDSWebViewAssembly
    ) {
        self.threeDSService = threeDSService
        self.threeDSWebViewAssembly = threeDSWebViewAssembly
    }

    // MARK: IThreeDSUIHandler

    func confirm3DS(
        data: Confirmation3DSData,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void
    ) {
        present3DSWebView(
            urlRequest: try threeDSService.createConfirmation3DSRequest(data: data),
            completion: completion
        )
    }

    func confirm3DSACS(
        data: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void
    ) {
        present3DSWebView(
            urlRequest: try threeDSService.createConfirmation3DSRequestACS(data: data, messageVersion: messageVersion),
            completion: completion
        )
    }

    func complete3DSMethod(checking3DSURLData: Checking3DSURLData) throws {
        let request = try threeDSService.createChecking3DSURL(data: checking3DSURLData)
        let uiProvider = try webFlowDelegate.orThrow(Error.missingWebFlowDelegate)
        uiProvider.hiddenWebViewToCollect3DSData().load(request)
    }

    // MARK: Helpers

    private func present3DSWebView<Payload: Decodable>(
        urlRequest: @autoclosure () throws -> URLRequest,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) {
        do {
            let uiProvider = try webFlowDelegate.orThrow(Error.missingWebFlowDelegate)
            let sourceViewController = try uiProvider.sourceViewControllerToPresent()
                .orThrow(Error.missingSourceViewController)

            let urlRequest = try urlRequest()

            let navigationController = threeDSWebViewAssembly.threeDSWebViewNavigationController(
                urlRequest: urlRequest,
                completion: completion
            )

            sourceViewController.present(navigationController, animated: true)
        } catch {
            completion(.failed(error))
        }
    }
}

// MARK: - ThreeDSWebFlowController.Error + LocalizedError

extension ThreeDSWebFlowController.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingWebFlowDelegate:
            return "You should set `ThreeDSWebFlowDelegate` for correct handling 3DS Web Flow"
        case .missingSourceViewController:
            return "You should provide `sourceViewControllerToPresent` in `ThreeDSWebFlowDelegate` implementation for correct handling 3DS Web Flow"
        }
    }
}
