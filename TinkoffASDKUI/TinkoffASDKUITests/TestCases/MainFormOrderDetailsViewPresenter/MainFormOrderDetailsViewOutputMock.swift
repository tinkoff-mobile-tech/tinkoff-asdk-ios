//
//  MainFormOrderDetailsViewOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 09.06.2023.
//

@testable import TinkoffASDKUI

final class MainFormOrderDetailsViewOutputMock: IMainFormOrderDetailsViewOutput {
    var view: IMainFormOrderDetailsViewInput?

    // MARK: - copy

    var copyCallsCount = 0
    var copyReturnValue: (any IMainFormOrderDetailsViewOutput)?

    func copy() -> any IMainFormOrderDetailsViewOutput {
        copyCallsCount += 1
        return copyReturnValue!
    }

    static func == (lhs: MainFormOrderDetailsViewOutputMock, rhs: MainFormOrderDetailsViewOutputMock) -> Bool {
        return lhs.view === rhs.view
    }
}
