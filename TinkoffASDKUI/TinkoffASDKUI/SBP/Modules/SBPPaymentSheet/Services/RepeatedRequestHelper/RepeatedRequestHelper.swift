//
//  RepeatedRequestHelper.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 17.01.2023.
//

import Foundation
import TinkoffASDKCore

final class RepeatedRequestHelper: IRepeatedRequestHelper {

    // MARK: Properties

    /// От этого параметра зависит, какая будет задержка между повторяющимися операциями
    private let delay: TimeInterval

    private var lastExecutionTime = Date(timeIntervalSince1970: 0)

    // MARK: Initialization

    init(delay: TimeInterval) {
        self.delay = delay
    }

    // MARK: IRepeatedRequestHelper

    /// Выполняет переданный блок кода не раньше заданного времени `var delay: TimeInterval`
    /// Пример: delay = 10
    /// Первый вызов будет осуществлен мгновенно.
    /// А вот следующий будет исполнен только после задержки. Когда пройдет установленное время.
    /// Важно! Если накидать пять операций подряд, то все они будут выполнены одновременно после задержки.
    /// За этим моментом необходимо следить самостоятельно.
    /// - Parameter action: Блок который должен быть выполнен
    func executeWithWaitingIfNeeded(action: @escaping VoidBlock) {
        let currentTime = Date()
        let differenceInSeconds = currentTime.timeIntervalSince(lastExecutionTime)

        if differenceInSeconds > delay {
            lastExecutionTime = Date()
            action()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + (delay - differenceInSeconds)) {
                self.lastExecutionTime = Date()
                action()
            }
        }
    }
}
