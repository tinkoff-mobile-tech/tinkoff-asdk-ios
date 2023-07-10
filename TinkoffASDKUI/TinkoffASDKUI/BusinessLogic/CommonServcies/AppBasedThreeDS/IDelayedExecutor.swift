//
//  ITDSWrapper.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 06.07.2023.
//

import Foundation

/// Отложенное исполнение кода
protocol IDelayedExecutor {
    /// Задержка в секундах
    var delay: Double { get }
    /// Очередь на которой запустится работа
    var queue: IDispatchQueue { get }
    /// Выполняет отложенное исполнение кода
    func execute(work: @escaping () -> Void)
}

struct DelayedExecutor: IDelayedExecutor {
    let delay: Double
    let queue: IDispatchQueue

    func execute(work: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + delay, flags: .barrier, execute: work)
    }
}

extension DelayedExecutor {
    /// Почти мгновенное исполнение кода на главном потоке
    static func buildDefault() -> DelayedExecutor {
        DelayedExecutor(delay: 0.1, queue: DispatchQueue.main)
    }
}
