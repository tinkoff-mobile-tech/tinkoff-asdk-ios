//
//  ITimerProvider.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 28.06.2023.
//

import Foundation

protocol ITimerProvider {
    func invalidateTimer()

    func executeTimer(timeInterval: TimeInterval, repeats: Bool, action: @escaping () -> Void)
}

extension ITimerProvider {
    func executeTimer(timeInterval: TimeInterval, action: @escaping () -> Void) {
        executeTimer(timeInterval: timeInterval, repeats: false, action: action)
    }
}
