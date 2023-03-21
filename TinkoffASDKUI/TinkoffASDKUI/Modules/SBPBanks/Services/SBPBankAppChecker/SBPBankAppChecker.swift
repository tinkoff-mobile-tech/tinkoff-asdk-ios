//
//  SBPBankAppChecker.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.12.2022.
//

import Foundation
import TinkoffASDKCore

final class SBPBankAppChecker: ISBPBankAppChecker {

    // MARK: Dependencies

    private let appChecker: IAppChecker

    // MARK: Initialization

    init(appChecker: IAppChecker) {
        self.appChecker = appChecker
    }

    // MARK: ISBPBankAppChecker

    /// Принимает список банков из которых происходит выборка по следующей логике:
    /// Смотрит в Info.plist мерча и осталяет только те банки которые указанны в этом Info.plist (это те банки которые мерч считает наиболее предпочтительными для совершения оплаты)
    /// Далее из желаемого мерчом списка удалются все те, которые не установленны на устройстве пользователя
    /// И после всех манипуляций возвращает список оставшихся банков
    /// - Parameter allBanks: Список банков из которых будет производится выборка
    /// - Returns: Список банков подходящие под условия
    func bankAppsPreferredByMerchant(from allBanks: [SBPBank]) -> [SBPBank] {
        allBanks.filter { appChecker.checkApplication(withScheme: $0.schema) == .installed }
    }
}
