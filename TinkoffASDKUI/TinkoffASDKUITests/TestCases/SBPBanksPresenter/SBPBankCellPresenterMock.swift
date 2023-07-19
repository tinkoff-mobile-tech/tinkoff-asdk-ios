//
//  SBPBankCellPresenterMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 24.04.2023.
//

@testable import TinkoffASDKUI

final class SBPBankCellPresenterMock: ISBPBankCellPresenter {
    var cell: ISBPBankCell?

    var bankName: String {
        get { return underlyingBankName }
        set(value) { underlyingBankName = value }
    }

    var underlyingBankName: String!

    var action: VoidBlock {
        get { return underlyingAction }
        set(value) { underlyingAction = value }
    }

    var underlyingAction: VoidBlock!

    // MARK: - startLoadingCellImageIfNeeded

    var startLoadingCellImageIfNeededCallsCount = 0

    func startLoadingCellImageIfNeeded() {
        startLoadingCellImageIfNeededCallsCount += 1
    }
}

// MARK: - Resets

extension SBPBankCellPresenterMock {
    func fullReset() {
        startLoadingCellImageIfNeededCallsCount = 0
    }
}
