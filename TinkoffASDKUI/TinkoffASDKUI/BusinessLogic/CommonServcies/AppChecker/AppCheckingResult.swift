//
//  AppCheckingResult.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 03.03.2023.
//

import Foundation

/// Результат проверки наличия установленного приложения с указанной схемой
enum AppCheckingResult {
    /// Приложение установлено
    case installed
    /// Приложения не установлено
    case notInstalled
    /// Ответ неоднозначный.
    /// Для корректной проверки доступности приложения необходимо указать переданную схему в info.plist с ключом `LSApplicationQueriesSchemes`
    case ambiguous
}
