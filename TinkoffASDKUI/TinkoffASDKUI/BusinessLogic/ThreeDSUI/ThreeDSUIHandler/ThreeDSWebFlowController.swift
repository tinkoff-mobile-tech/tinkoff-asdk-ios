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
        case uiProviderDoesNotExist
        case sourceViewControllerDoesNotExist
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
        resultHandler: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) {
        present3DSWebView(
            urlRequest: try threeDSService.createConfirmation3DSRequest(data: data),
            resultHandler: resultHandler
        )
    }

    func confirm3DSACS<Payload: Decodable>(
        data: Confirmation3DSDataACS,
        messageVersion: String,
        resultHandler: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) {
        present3DSWebView(
            urlRequest: try threeDSService.createConfirmation3DSRequestACS(data: data, messageVersion: messageVersion),
            resultHandler: resultHandler
        )
    }

    func complete3DSMethod(checking3DSURLData: Checking3DSURLData) throws {
        let request = try threeDSService.createChecking3DSURL(data: checking3DSURLData)
        let uiProvider = try uiProvider.orThrow(Error.uiProviderDoesNotExist)
        uiProvider.hiddenWebViewToCollect3DSData().load(request)
    }

    // MARK: Helpers

    private func present3DSWebView<Payload: Decodable>(
        urlRequest: @autoclosure () throws -> URLRequest,
        resultHandler: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) {
        do {
            let uiProvider = try uiProvider.orThrow(Error.uiProviderDoesNotExist)
            let sourceViewController = try uiProvider.sourceViewControllerToPresent()
                .orThrow(Error.sourceViewControllerDoesNotExist)

            let urlRequest = try urlRequest()

            let navigationController = threeDSWebViewAssembly.threeDSWebViewNavigationController(
                urlRequest: urlRequest,
                resultHandler: resultHandler
            )

            sourceViewController.present(navigationController, animated: true)
        } catch {
            resultHandler(.finished(payload: .failure(error)))
        }
    }
}

// MARK: - ThreeDSWebFlowController.Error + LocalizedError

extension ThreeDSWebFlowController.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .uiProviderDoesNotExist:
            return "You should set `UIProvider` for correct handling 3DS Web Flow"
        case .sourceViewControllerDoesNotExist:
            return "You should provide `sourceViewControllerToPresent` for correct handling 3DS Web Flow"
        }
    }
}
