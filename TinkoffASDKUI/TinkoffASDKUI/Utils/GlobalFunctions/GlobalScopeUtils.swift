//
//  GlobalScopeUtils.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 01.02.2023.
//

/// Создает измененную копию исходного значения на основе замыкания
func modify<T>(_ value: T, _ modifier: (inout T) -> Void) -> T {
    var value = value
    modifier(&value)
    return value
}
