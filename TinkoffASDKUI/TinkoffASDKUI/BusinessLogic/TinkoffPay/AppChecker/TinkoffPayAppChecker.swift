//
//  TinkoffPayAppChecker.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 02.03.2023.
//

import Foundation

final class TinkoffPayAppChecker: ITinkoffPayAppChecker {
    // MARK: Dependencies

    private let appChecker: IAppChecker
    private let tinkoffPaySchemes: [String]

    // MARK: Init

    init(
        appChecker: IAppChecker,
        tinkoffPaySchemes: [String] = .tinkoffPaySchemes
    ) {
        self.appChecker = appChecker
        self.tinkoffPaySchemes = tinkoffPaySchemes
    }

    // MARK: ITinkoffPayAppChecker

    func isTinkoffPayAppInstalled() -> Bool {
        tinkoffPaySchemes.contains { appChecker.checkApplication(withScheme: $0) == .installed }
    }
}

// MARK: - Constants

private extension Array where Element == String {
    static var tinkoffPaySchemes: [String] {
        ["tinkoffbank"]
    }
}
