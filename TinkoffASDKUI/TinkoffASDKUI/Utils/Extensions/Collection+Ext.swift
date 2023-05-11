//
//  Collection+Ext.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 11.05.2023.
//

extension Collection {
    /// Безопасно достает элемент из массива по сабскрипту
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
