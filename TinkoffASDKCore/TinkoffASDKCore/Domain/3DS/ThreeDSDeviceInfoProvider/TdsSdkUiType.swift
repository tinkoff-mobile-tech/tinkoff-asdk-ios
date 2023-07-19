//
//  TdsSdkUiType.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 19.07.2023.
//

import Foundation

/// UI (макет) сценарий по которому будет проведена проверка
///
/// html + htmlObb - только для sdkInterface == HTML
public enum TdsSdkUiType: String, CaseIterable, Codable {
    /// Текстовый отп
    case text = "01"
    /// Радиобаттон
    case singleSelect = "02"
    /// Чекмарки
    case multiSelect = "03"
    case oob = "04"
    /// Своя html форма
    case html = "05"
    case htmlOob = "06"
    case information = "07"

    static func allValues() -> String {
        Self.allCases.map { $0.rawValue }.joined(separator: ",")
    }
}
