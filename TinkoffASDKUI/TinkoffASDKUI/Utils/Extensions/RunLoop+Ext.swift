//
//  RunLoop+Ext.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 22.06.2023.
//

import Foundation

extension RunLoop {
    /// Запущен ли ранлуп
    var isRunning: Bool { currentMode != nil }
}
