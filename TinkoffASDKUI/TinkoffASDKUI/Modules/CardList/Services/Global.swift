//
//  Global.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.09.2022.
//

import Foundation

// MARK: - Typealiases

typealias WeakArray<T> = [() -> T?]

// MARK: - Глобальные полезные функции

func performOnMain(block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
