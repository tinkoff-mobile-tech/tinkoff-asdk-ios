//
//  SBPBankAppChecker.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.12.2022.
//

import TinkoffASDKCore

private extension String {
    static let bankSchemesKey = "LSApplicationQueriesSchemes"
}

final class SBPBankAppChecker: ISBPBankAppChecker {

    // Dependencies
    private let application: IUIApplication

    // MARK: - Initialization

    public init(application: IUIApplication) {
        self.application = application
    }

    // MARK: - ISBPBankAppChecker

    func bankAppsPreferredByMerchant(from allBanks: [SBPBank]) -> [SBPBank] {
        if let bankSchemesArray = Bundle.main.infoDictionary?[.bankSchemesKey] as? [String] {
            var preferredBanks = allBanks.filter { bank in bankSchemesArray.contains(where: { $0 == bank.schema }) }
            preferredBanks = preferredBanks.filter { isBankAppInstalled($0) }
            return preferredBanks
        } else {
            return []
        }
    }

    func openBankApp(_ bank: SBPBank) {
        guard let url = URL(string: "\(bank.schema)://") else { return }
        application.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - Private

extension SBPBankAppChecker {
    private func isBankAppInstalled(_ bank: SBPBank) -> Bool {
        guard let url = URL(string: "\(bank.schema)://") else { return false }
        return application.canOpenURL(url)
    }
}
