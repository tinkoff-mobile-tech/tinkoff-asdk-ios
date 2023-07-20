//
//  QrImageViewPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 17.05.2023.
//

import Foundation
@testable import TinkoffASDKUI

final class QrImageViewPresenterOutputMock: IQrImageViewPresenterOutput {

    // MARK: - qrDidLoad

    var qrDidLoadCallsCount = 0

    func qrDidLoad() {
        qrDidLoadCallsCount += 1
    }
}

// MARK: - Resets

extension QrImageViewPresenterOutputMock {
    func fullReset() {
        qrDidLoadCallsCount = 0
    }
}
