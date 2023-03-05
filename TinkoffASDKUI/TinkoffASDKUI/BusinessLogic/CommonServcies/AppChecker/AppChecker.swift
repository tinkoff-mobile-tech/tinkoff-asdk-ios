//
//  AppChecker.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 03.03.2023.
//

import Foundation
import class UIKit.UIApplication

final class AppChecker: IAppChecker {
    // MARK: Dependencies

    private let application: IUIApplication
    private let queriesSchemes: Set<String>

    // MARK: Init

    init(
        application: IUIApplication = UIApplication.shared,
        queriesSchemes: Set<String> = Bundle.queriesSchemes
    ) {
        self.application = application
        self.queriesSchemes = queriesSchemes
    }

    // MARK: IAppChecker

    func checkApplication(withScheme scheme: String) -> AppCheckingResult {
        guard queriesSchemes.contains(scheme) else {
            return .ambiguous
        }

        guard let appUrl = URL(string: "\(scheme)://") else {
            return .notInstalled
        }

        return application.canOpenURL(appUrl) ? .installed : .notInstalled
    }
}

private extension Bundle {
    static var queriesSchemes: Set<String> {
        Bundle.main
            .infoDictionary
            .flatMap { $0["LSApplicationQueriesSchemes"] as? [String] }
            .map(Set.init) ?? []
    }
}
