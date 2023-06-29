//
//  RepeatedRequestHelper.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import Foundation
import TinkoffASDKCore

final class RepeatedRequestHelper: IRepeatedRequestHelper {

    // MARK: Dependencies

    private let timerProvider: ITimerProvider

    // MARK: Properties

    /// От этого параметра зависит, какая будет задержка между повторяющимися операциями
    private let delay: TimeInterval

    private var lastExecutionTime = Date(timeIntervalSince1970: 0)

    // MARK: Initialization

    init(
        timerProvider: ITimerProvider = TimerProvider(),
        delay: TimeInterval = .paymentStatusRequestDelay
    ) {
        self.timerProvider = timerProvider
        self.delay = delay
    }

    deinit {
        timerProvider.invalidateTimer()
    }

    // MARK: IRepeatedRequestHelper

    /// Выполняет переданный блок кода не раньше заданного времени `var delay: TimeInterval`
    ///
    /// Пример: delay = 10
    /// Первый вызов будет осуществлен мгновенно.
    /// А вот следующий будет исполнен только после задержки. Когда пройдет установленное время.
    /// Важно! Если накидать несколько операций подряд, то будет выполнена только последняя с соблюдением условий задержки.
    /// Важно! Для корректной работы необходимо отправлять задачи с одного и того же потока
    /// - Parameter action: Блок который должен быть выполнен
    func executeWithWaitingIfNeeded(action: @escaping () -> Void) {
        timerProvider.invalidateTimer()

        let currentTime = Date()
        let differenceInSeconds = currentTime.timeIntervalSince(lastExecutionTime)

        if differenceInSeconds > delay {
            lastExecutionTime = Date()
            action()
        } else {
            let actionDecorator = { [weak self] in
                self?.lastExecutionTime = Date()
                action()
            }

            timerProvider.executeTimer(timeInterval: delay - differenceInSeconds, action: actionDecorator)
        }
    }
}

// MARK: - Constants

private extension TimeInterval {
    static let paymentStatusRequestDelay: TimeInterval = 3
}
