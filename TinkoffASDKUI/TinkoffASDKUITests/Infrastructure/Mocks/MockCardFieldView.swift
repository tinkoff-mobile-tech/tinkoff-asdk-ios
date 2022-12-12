//
//  MockCardFieldView.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation

final class MockCardFieldView: ICardFieldView {

    var isActive: Bool = false

    // MARK: - activateExpirationField

    var activateExpirationFieldCallCounter = 0

    func activateExpirationField() {
        activateExpirationFieldCallCounter += 1
    }

    // MARK: - activateCvcField

    var activateCvcFieldCallCounter = 0

    func activateCvcField() {
        activateCvcFieldCallCounter += 1
    }

    // MARK: - activate

    var activateCallCounter = 0

    func activate() {
        activateCallCounter += 1
    }

    // MARK: - deactivateCallCounter

    var deactivateCallCounter = 0

    func deactivate() {
        deactivateCallCounter += 1
    }
}
