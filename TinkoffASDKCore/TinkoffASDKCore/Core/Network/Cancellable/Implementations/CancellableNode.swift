//
//  CancellableNode.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 29.09.2022.
//

import Foundation

final class CancellableNode: Cancellable {
    typealias VoidClosure = () -> Void

    var isCancelled: Bool {
        synchronizer.sync { _isCancelled }
    }

    private var _isCancelled = false
    private let synchronizer: Synchronizable
    private var cancellationHandler: VoidClosure?

    init(synchronizer: Synchronizable = NSLock()) {
        self.synchronizer = synchronizer
    }

    func addCancellationHandler(_ handler: @escaping VoidClosure) {
        let cancelNow: VoidClosure? = synchronizer.sync {
            if _isCancelled {
                return handler
            } else {
                self.cancellationHandler = handler
                return nil
            }
        }

        cancelNow?()
    }

    func cancel() {
        let cancellationHandler: VoidClosure? = synchronizer.sync {
            defer {
                self._isCancelled = true
                self.cancellationHandler = nil
            }

            return self.cancellationHandler
        }

        cancellationHandler?()
    }
}
