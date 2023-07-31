//
//  ProgressDialogMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 07.07.2023.
//

import TdsSdkIos

final class ProgressDialogMock: ProgressDialog {

    // MARK: - start

    var startCallsCount = 0

    func start() {
        startCallsCount += 1
    }

    // MARK: - stop

    var stopCallsCount = 0

    func stop() {
        stopCallsCount += 1
    }
}

// MARK: - Resets

extension ProgressDialogMock {
    func fullReset() {
        startCallsCount = 0

        stopCallsCount = 0
    }
}
