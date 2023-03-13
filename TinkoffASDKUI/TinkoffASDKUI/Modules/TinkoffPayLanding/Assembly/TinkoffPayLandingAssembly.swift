//
//  TinkoffPayLandingAssembly.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 13.03.2023.
//

import Foundation

final class TinkoffPayLandingAssembly: ITinkoffPayLandingAssembly {
    // MARK: Dependencies

    private let authChallengeService: IWebViewAuthChallengeService

    // MARK: Init

    init(authChallengeService: IWebViewAuthChallengeService) {
        self.authChallengeService = authChallengeService
    }

    // MARK: ITinkoffPayLandingAssembly

    func landingNavigationController() -> UINavigationController {
        let viewController = TinkoffPayLandingViewController(authChallengeService: authChallengeService)
        return UINavigationController.withTransparentBar(rootViewController: viewController)
    }
}
