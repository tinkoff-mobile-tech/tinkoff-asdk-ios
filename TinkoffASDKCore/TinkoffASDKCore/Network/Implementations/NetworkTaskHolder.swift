//
//  NetworkTaskHolder.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 29.09.2022.
//

import Foundation

final class NetworkTaskHolder: Cancellable {
    // MARK: Lock

    private let lock = NSLock()

    // MARK: Mutable State

    private var isCancelled = false
    private var task: Cancellable?

    // MARK: Actions

    /// Сохраняет ссылку на отменяемую задачу, если у контейнера не был вызван `cancel()`
    /// - Parameter task: Задача, которую нужно сохранить
    /// - Returns: Флаг, об успешности сохранения задачи:
    /// `true` - задача сохранена, и готова к запуску
    /// `false` - вышестоящая задача была отменена,  запуск не требуется
    func store(_ task: Cancellable) -> Bool {
        lock.sync {
            if !isCancelled {
                self.task = task
            }
            return !isCancelled
        }
    }

    func cancel() {
        let task: Cancellable? = lock.sync {
            defer {
                self.isCancelled = true
                self.task = nil
            }
            return task
        }

        task?.cancel()
    }
}
