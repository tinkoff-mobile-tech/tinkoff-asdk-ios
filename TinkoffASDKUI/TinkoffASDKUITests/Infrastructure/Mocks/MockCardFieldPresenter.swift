//
//  MockCardFieldPresenter.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 28.12.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockCardFieldPresenter: ICardFieldPresenter {
    var getCardFieldView: () -> ICardFieldView? = { nil }
    var config: CardFieldView.Config?
    var validationResult = CardFieldPresenter.ValidationResult()
    var validationResultDidChange: ((CardFieldPresenter.ValidationResult) -> Void)?
    var cardNumber: String = ""
    var expiration: String = ""
    var cvc: String = ""

    var validateWholeFormCallCounter = 0
    var validateWholeFormStub: () -> CardFieldPresenter.ValidationResult = { CardFieldPresenter.ValidationResult() }
    func validateWholeForm() -> CardFieldPresenter.ValidationResult {
        validateWholeFormCallCounter += 1
        return validateWholeFormStub()
    }

    var didFillCardNumberCallCounter = 0
    var didFillCardNumberStub: (String, Bool) -> Void = { _, _ in }
    func didFillCardNumber(text: String, filled: Bool) {
        didFillCardNumberCallCounter += 1
        didFillCardNumberStub(text, filled)
    }

    var didFillExpirationCallCounter = 0
    var didFillExpirationStub: (String, Bool) -> Void = { _, _ in }
    func didFillExpiration(text: String, filled: Bool) {
        didFillExpirationCallCounter += 1
        didFillCardNumberStub(text, filled)
    }

    var didFillCvcCallCounter = 0
    var didFillCvcStub: (String, Bool) -> Void = { _, _ in }
    func didFillCvc(text: String, filled: Bool) {
        didFillCvcCallCounter += 1
        didFillCvcStub(text, filled)
    }
}
