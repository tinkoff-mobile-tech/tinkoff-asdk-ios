//
//  IMoneyFormatter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

protocol IMoneyFormatter {
    /// Создает строку с ценой добавляя в конце знак рубля - ₽
    /// - Parameter amount: Цена в копейках
    /// - Returns: Возвращает строку. Пример формата: 10 534,41 ₽
    func formatAmount(_ amount: Int) -> String
}
