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

    private weak var timer: Timer?

    // MARK: Properties

    /// От этого параметра зависит, какая будет задержка между повторяющимися операциями
    private let delay: TimeInterval

    private var lastExecutionTime = Date(timeIntervalSince1970: 0)

    // MARK: Initialization

    init(delay: TimeInterval = .paymentStatusRequestDelay) {
        self.delay = delay
    }

    deinit {
        timer?.invalidate()
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
        timer?.invalidate()

        let currentTime = Date()
        let differenceInSeconds = currentTime.timeIntervalSince(lastExecutionTime)

        if differenceInSeconds > delay {
            lastExecutionTime = Date()
            action()
        } else {
            let timer = Timer(timeInterval: delay - differenceInSeconds, repeats: false) { [weak self] _ in
                self?.lastExecutionTime = Date()
                action()
            }
            self.timer = timer

            RunLoop.current.add(timer, forMode: .common)
            if !RunLoop.current.isRunning {
                // Важно! Нужно явно запустить ранлуп, иначе таймер не будет работать
                RunLoop.current.run()
            }
        }
    }
}

// MARK: - Constants

private extension TimeInterval {
    static let paymentStatusRequestDelay: TimeInterval = 3
}

private extension RunLoop {
    /// Запущен ли ранлуп
    var isRunning: Bool { currentMode != nil }
}
