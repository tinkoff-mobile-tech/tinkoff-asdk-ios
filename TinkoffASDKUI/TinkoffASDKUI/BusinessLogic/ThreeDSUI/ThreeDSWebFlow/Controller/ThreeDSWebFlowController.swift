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
        case missingUIProvider
        case missingSourceViewController
    }

    // MARK: Dependencies

    weak var uiProvider: PaymentControllerUIProvider?
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

    func confirm3DS<Payload: Decodable>(
        data: Confirmation3DSData,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) {
        present3DSWebView(
            urlRequest: try threeDSService.createConfirmation3DSRequest(data: data),
            completion: completion
        )
    }

    func confirm3DSACS<Payload: Decodable>(
        data: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) {
        present3DSWebView(
            urlRequest: try threeDSService.createConfirmation3DSRequestACS(data: data, messageVersion: messageVersion),
            completion: completion
        )
    }

    func complete3DSMethod(checking3DSURLData: Checking3DSURLData) throws {
        let request = try threeDSService.createChecking3DSURL(data: checking3DSURLData)
        let uiProvider = try uiProvider.orThrow(Error.missingUIProvider)
        uiProvider.hiddenWebViewToCollect3DSData().load(request)
    }

    // MARK: Helpers

    private func present3DSWebView<Payload: Decodable>(
        urlRequest: @autoclosure () throws -> URLRequest,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) {
        do {
            let uiProvider = try uiProvider.orThrow(Error.missingUIProvider)
            let sourceViewController = try uiProvider.sourceViewControllerToPresent()
                .orThrow(Error.missingSourceViewController)

            let urlRequest = try urlRequest()

            let navigationController = threeDSWebViewAssembly.threeDSWebViewNavigationController(
                urlRequest: urlRequest,
                resultHandler: completion
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
        case .missingUIProvider:
            return "You should set `ThreeDSUIProvider` for correct handling 3DS Web Flow"
        case .missingSourceViewController:
            return "You should provide `sourceViewControllerToPresent` in `IThreeDSUIProvider` implementation for correct handling 3DS Web Flow"
        }
    }
}
