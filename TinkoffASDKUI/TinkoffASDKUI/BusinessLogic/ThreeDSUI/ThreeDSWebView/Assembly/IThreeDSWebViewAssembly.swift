//
//  IThreeDSViewControllerAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 17.02.2023.
//

import Foundation
import TinkoffASDKCore
import UIKit

protocol IThreeDSWebViewAssembly {
    func threeDSWebViewController<Payload: Decodable>(
        urlRequest: URLRequest,
        resultHandler: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) -> UIViewController

    func threeDSWebViewNavigationController<Payload: Decodable>(
        urlRequest: URLRequest,
        resultHandler: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    ) -> UINavigationController
}
