//
//  TimerProvider.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 28.06.2023.
//

import Foundation

final class TimerProvider: ITimerProvider {

    // MARK: Dependencies

    private weak var timer: Timer?

    // MARK: ITimerProvider

    func invalidateTimer() {
        timer?.invalidate()
    }

    func executeTimer(timeInterval: TimeInterval, repeats: Bool, action: @escaping () -> Void) {
        let timer = Timer(timeInterval: timeInterval, repeats: repeats) { _ in action() }
        self.timer = timer

        RunLoop.current.add(timer, forMode: .common)
        // Запускает RunLoop если не запущен на текущем потоке, без запущенного RunLoop timer(ы) не работают!!
        RunLoop.current.runIfNeeded()
    }
}
