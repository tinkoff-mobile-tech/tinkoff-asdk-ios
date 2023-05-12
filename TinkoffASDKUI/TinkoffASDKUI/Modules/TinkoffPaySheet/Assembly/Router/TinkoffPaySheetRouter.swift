//
//  TinkoffPaySheetRouter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 13.03.2023.
//

import Foundation
import UIKit

final class TinkoffPaySheetRouter: ITinkoffPaySheetRouter {
    // MARK: Dependencies

    weak var transitionHandler: UIViewController?
    private let tinkoffPayLandingAssembly: ITinkoffPayLandingAssembly

    // MARK: Init

    init(tinkoffPayLandingAssembly: ITinkoffPayLandingAssembly) {
        self.tinkoffPayLandingAssembly = tinkoffPayLandingAssembly
    }

    // MARK: ITinkoffPaySheetRouter

    func openTinkoffPayLanding(completion: VoidBlock?) {
        let navigationController = tinkoffPayLandingAssembly.landingNavigationController()

        transitionHandler?.present(navigationController, animated: true)
    }
}
