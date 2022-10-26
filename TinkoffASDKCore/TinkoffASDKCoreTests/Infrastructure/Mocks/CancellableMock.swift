//
//  CancellableMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by r.akhmadeev on 24.10.2022.
//

import Foundation
import TinkoffASDKCore

final class CancellableMock: Cancellable {
    var invokedCancel = false
    var invokedCancelCount = 0

    func cancel() {
        invokedCancel = true
        invokedCancelCount += 1
    }
}
