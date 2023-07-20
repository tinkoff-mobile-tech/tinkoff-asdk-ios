//
//  TextAndImageHeaderViewOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

@testable import TinkoffASDKUI

final class TextAndImageHeaderViewOutputMock: ITextAndImageHeaderViewOutput {
    var view: ITextAndImageHeaderViewInput?

    // MARK: - copy

    var copyCallsCount = 0
    var copyReturnValue: TextAndImageHeaderViewOutputMock?

    func copy() -> any ITextAndImageHeaderViewOutput {
        copyCallsCount += 1
        return copyReturnValue ?? TextAndImageHeaderViewOutputMock()
    }

    static func == (lhs: TextAndImageHeaderViewOutputMock, rhs: TextAndImageHeaderViewOutputMock) -> Bool {
        return lhs.view === rhs.view
    }
}

// MARK: - Resets

extension TextAndImageHeaderViewOutputMock {
    func fullReset() {
        copyCallsCount = 0
    }
}
