//
//  MoneyFormatter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

import Foundation

final class MoneyFormatter: IMoneyFormatter {

    // MARK: Dependencies

    private let numberFormatter: NumberFormatter

    // MARK: Initialization

    init(numberFormatter: NumberFormatter = NumberFormatter()) {
        self.numberFormatter = numberFormatter
    }

    // MARK: IMoneyFormatter

    /// Создает строку с ценой добавляя в конце знак рубля - ₽
    /// - Parameter amount: Цена в копейках
    /// - Returns: Возвращает строку. Пример формата: 10 534,41 ₽
    func formatAmount(_ amount: Int) -> String {
        let decimalValue = NSDecimalNumber(decimal: Decimal(Double(amount) / 100))

        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSize = 3
        numberFormatter.groupingSeparator = " "
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.decimalSeparator = ","
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2

        return "\(numberFormatter.string(from: decimalValue) ?? "\(decimalValue)") ₽"
    }
}
