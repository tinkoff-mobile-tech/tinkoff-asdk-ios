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
    /// Out of band (OOB) authentication represents the authentication mechanism
    /// that involves the presence of two varied signals from two distinct channels or networks.
    case oob = "04"
    /// Своя html форма
    case html = "05"

    static func allValues() -> String {
        Self.allCases.map { $0.rawValue }.joined(separator: ",")
    }
}
