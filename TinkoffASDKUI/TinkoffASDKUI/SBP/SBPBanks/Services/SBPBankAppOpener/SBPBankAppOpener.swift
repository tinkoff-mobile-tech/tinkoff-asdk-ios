//
//  SBPBankAppOpener.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import Foundation
import TinkoffASDKCore

final class SBPBankAppOpener: ISBPBankAppOpener {

    // MARK: Dependencies

    private let application: IUIApplication

    // MARK: Initialization

    init(application: IUIApplication) {
        self.application = application
    }

    // MARK: ISBPBankAppOpener

    /// Пытается открыть приложение конкретного банка c платежной информацией содержащейся в урле
    /// - Parameters:
    ///   - url: Урла полученная из платежного QR
    ///   - bank: Банк, приложение которого надо открыть
    ///   - completion: Возвращает true если получилось открыть приложение банка, false если нет
    func openBankApp(url: URL, _ bank: SBPBank, completion: @escaping SBPBankAppCheckerOpenBankAppCompletion) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.scheme = bank.schema

        guard let resultUrl = components?.url else { return completion(false) }

        application.open(resultUrl, options: [:], completionHandler: completion)
    }
}
