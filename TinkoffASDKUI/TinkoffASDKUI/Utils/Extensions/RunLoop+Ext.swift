//
//  RunLoop+Ext.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 22.06.2023.
//

import Foundation

extension RunLoop {
    /// Показывает запущен ли RunLoop
    var isRunning: Bool { currentMode != nil }

    /// Запускает RunLoop, если он не запущет на текущем потоке
    func runIfNeeded() {
        if !isRunning {
            run()
        }
    }
}
