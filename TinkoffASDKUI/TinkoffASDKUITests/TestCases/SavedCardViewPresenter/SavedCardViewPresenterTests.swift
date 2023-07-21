//
//  SavedCardViewPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

import Foundation
import UIKit
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SavedCardViewPresenterTests: BaseTestCase {

    var sut: SavedCardViewPresenter!

    // MARK: Mocks

    var viewMock: SavedCardViewInputMock!
    var validatorMock: CardRequisitesValidatorMock!
    var paymentSystemResolverMock: PaymentSystemResolverMock!
    var bankResolverMock: BankResolverMock!
    var outputMock: SavedCardViewPresenterOutputMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        validatorMock = nil
        paymentSystemResolverMock = nil
        bankResolverMock = nil
        outputMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_activateCVCField() {
        // when
        sut.activateCVCField()

        // then
        XCTAssertEqual(viewMock.activateCVCFieldCallsCount, 1)
    }

    func test_setupView_when_shouldActivateOnSetup_and_stateIdle() {
        // given
        sut.view = nil
        sut.activateCVCField()

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.activateCVCFieldCallsCount, 1)
        XCTAssertEqual(viewMock.updateCallsCount, 1)
        XCTAssertEqual(viewMock.updateReceivedArguments?.cardName, "")
        XCTAssertEqual(viewMock.updateReceivedArguments?.actionDescription, nil)
        XCTAssertEqual(viewMock.hideCVCFieldCallsCount, 1)
    }

    func test_presentationState_when_newState_and_showChangeDescriptionTrue() {
        // given
        let paymentCard = PaymentCard.fake()
        let changeButtonDescription = Loc.Acquiring.PaymentCard.changeButton

        // when
        sut.presentationState = .selected(card: paymentCard, showChangeDescription: true)

        // then
        XCTAssertEqual(viewMock.deactivateCVCFieldCallsCount, 1)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(bankResolverMock.resolveReceivedArguments, paymentCard.pan)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveReceivedArguments, paymentCard.pan)
        XCTAssertEqual(viewMock.updateCallsCount, 1)
        XCTAssertEqual(viewMock.updateReceivedArguments?.actionDescription, changeButtonDescription)
        XCTAssertEqual(viewMock.showCVCFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setCVCTextCallsCount, 1)
        XCTAssertEqual(viewMock.setCVCFieldValidCallsCount, 1)
    }

    func test_presentationState_when_newState_and_showChangeDescriptionFalse() {
        // given
        let paymentCard = PaymentCard.fake()

        // when
        sut.presentationState = .selected(card: paymentCard, showChangeDescription: false)

        // then
        XCTAssertEqual(viewMock.deactivateCVCFieldCallsCount, 1)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(bankResolverMock.resolveReceivedArguments, paymentCard.pan)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveReceivedArguments, paymentCard.pan)
        XCTAssertEqual(viewMock.updateCallsCount, 1)
        XCTAssertEqual(viewMock.updateReceivedArguments?.actionDescription, nil)
        XCTAssertEqual(viewMock.showCVCFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setCVCTextCallsCount, 1)
        XCTAssertEqual(viewMock.setCVCFieldValidCallsCount, 1)
    }

    func test_presentationState_when_newState_and_showChangeDescriptionFalse_and_hasUserInteractedWithCVCTrue() {
        // given
        let paymentCard = PaymentCard.fake()
        sut.savedCardViewDidBeginCVCFieldEditing()
        viewMock.fullReset()

        // when
        sut.presentationState = .selected(card: paymentCard, showChangeDescription: false)

        // then
        XCTAssertEqual(viewMock.deactivateCVCFieldCallsCount, 1)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(bankResolverMock.resolveReceivedArguments, paymentCard.pan)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveReceivedArguments, paymentCard.pan)
        XCTAssertEqual(viewMock.updateCallsCount, 1)
        XCTAssertEqual(viewMock.updateReceivedArguments?.actionDescription, nil)
        XCTAssertEqual(viewMock.showCVCFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setCVCTextCallsCount, 1)
        XCTAssertEqual(viewMock.setCVCFieldValidCallsCount, 1)
    }

    func test_presentationState_when_newState_and_wrongPan() {
        // given
        let paymentCard = PaymentCard(
            pan: "123",
            cardId: "111",
            status: .active,
            parentPaymentId: 123,
            expDate: nil
        )
        sut.savedCardViewDidBeginCVCFieldEditing()
        viewMock.fullReset()

        // when
        sut.presentationState = .selected(card: paymentCard, showChangeDescription: false)

        // then
        XCTAssertEqual(viewMock.deactivateCVCFieldCallsCount, 1)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(bankResolverMock.resolveReceivedArguments, paymentCard.pan)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveReceivedArguments, paymentCard.pan)
        XCTAssertEqual(viewMock.updateCallsCount, 1)
        XCTAssertEqual(viewMock.updateReceivedArguments?.actionDescription, nil)
        XCTAssertEqual(viewMock.showCVCFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setCVCTextCallsCount, 1)
        XCTAssertEqual(viewMock.setCVCFieldValidCallsCount, 1)
    }

    func test_presentationState_when_oldState() {
        // when
        sut.presentationState = .idle

        // then
        XCTAssertEqual(viewMock.deactivateCVCFieldCallsCount, 0)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 0)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 0)
        XCTAssertEqual(viewMock.updateCallsCount, 0)
        XCTAssertEqual(viewMock.showCVCFieldCallsCount, 0)
        XCTAssertEqual(viewMock.setCVCTextCallsCount, 0)
        XCTAssertEqual(viewMock.setCVCFieldValidCallsCount, 0)
    }

    func test_cardId_when_state_idl() {
        // given
        sut.presentationState = .idle

        // when
        let cardId = sut.cardId

        // given
        XCTAssertNil(cardId)
    }

    func test_cardId_when_state_selected() {
        // given
        let paymentCard = PaymentCard.fake()
        sut.presentationState = .selected(card: paymentCard)

        // when
        let cardId = sut.cardId

        // given
        XCTAssertEqual(cardId, paymentCard.cardId)
    }

    func test_cvc_whenValid() {
        // given
        let inputCvc = "111"
        validatorMock.validateInputCVCReturnValue = true
        sut.savedCardView(didChangeCVC: inputCvc)
        viewMock.fullReset()
        outputMock.fullReset()

        // when
        let cvc = sut.cvc

        // given
        XCTAssertEqual(cvc, inputCvc)
    }

    func test_cvc_whenNotValid() {
        // given
        validatorMock.validateInputCVCReturnValue = false

        // when
        let cvc = sut.cvc

        // given
        XCTAssertEqual(cvc, nil)
    }

    func test_savedCardViewDidChangeCVC_newValue() {
        // given
        sut.savedCardViewDidBeginCVCFieldEditing()
        viewMock.fullReset()

        let cvc = "12"

        // when
        sut.savedCardView(didChangeCVC: cvc)

        // then
        XCTAssertEqual(viewMock.setCVCFieldInvalidCallsCount, 1)
        XCTAssertEqual(outputMock.savedCardPresenterDidUpdateCVCCallsCount, 2)
        XCTAssertEqual(outputMock.savedCardPresenterDidUpdateCVCReceivedArguments?.cvc, cvc)
        XCTAssertEqual(outputMock.savedCardPresenterDidUpdateCVCReceivedArguments?.isValid, false)
    }

    func test_savedCardViewDidChangeCVC_oldValue() {
        // given
        let cvc = ""

        // when
        sut.savedCardView(didChangeCVC: cvc)

        // then
        XCTAssertEqual(viewMock.setCVCFieldInvalidCallsCount, 0)
        XCTAssertEqual(outputMock.savedCardPresenterDidUpdateCVCCallsCount, 0)
    }

    func test_savedCardViewDidBeginCVCFieldEditing_when_shouldShowValidState() {
        // when
        sut.savedCardViewDidBeginCVCFieldEditing()

        // then
        XCTAssertEqual(viewMock.setCVCFieldInvalidCallsCount, 1)
    }

    func test_savedCardViewDidBeginCVCFieldEditing_when_notShouldShowValidState() {
        // given
        validatorMock.validateInputCVCReturnValue = true

        // when
        sut.savedCardViewDidBeginCVCFieldEditing()

        // then
        XCTAssertEqual(viewMock.setCVCFieldValidCallsCount, 1)
    }

    func test_savedCardViewIsSelected_when_presentationState_idle() {
        // when
        sut.savedCardViewIsSelected()

        // then
        XCTAssertEqual(viewMock.deactivateCVCFieldCallsCount, 1)
        XCTAssertEqual(outputMock.savedCardPresenterDidUpdateCVCCallsCount, 0)
    }

    func test_savedCardViewIsSelected_when_presentationState_selected_and_showChangeDescriptionTrue() {
        // given
        let paymentCard = PaymentCard.fake()
        sut.presentationState = .selected(card: paymentCard, showChangeDescription: true)
        viewMock.fullReset()

        // when
        sut.savedCardViewIsSelected()

        // then
        XCTAssertEqual(viewMock.deactivateCVCFieldCallsCount, 1)
        XCTAssertEqual(outputMock.savedCardPresenterDidRequestReplacementForCallsCount, 1)
        XCTAssertEqual(outputMock.savedCardPresenterDidRequestReplacementForReceivedArguments?.paymentCard, paymentCard)
    }

    func test_savedCardViewIsSelected_when_presentationState_selected_and_showChangeDescriptionFalse() {
        // given
        let paymentCard = PaymentCard.fake()
        sut.presentationState = .selected(card: paymentCard, showChangeDescription: false)
        viewMock.fullReset()

        // when
        sut.savedCardViewIsSelected()

        // then
        XCTAssertEqual(viewMock.deactivateCVCFieldCallsCount, 1)
        XCTAssertEqual(outputMock.savedCardPresenterDidUpdateCVCCallsCount, 0)
    }
}

// MARK: - Private methods

extension SavedCardViewPresenterTests {
    private func setupSut() {
        viewMock = SavedCardViewInputMock()
        validatorMock = CardRequisitesValidatorMock()
        paymentSystemResolverMock = PaymentSystemResolverMock()
        bankResolverMock = BankResolverMock()
        outputMock = SavedCardViewPresenterOutputMock()

        sut = SavedCardViewPresenter(
            validator: validatorMock,
            paymentSystemResolver: paymentSystemResolverMock,
            bankResolver: bankResolverMock,
            output: outputMock
        )

        sut.view = viewMock
        viewMock.fullReset()
        validatorMock.fullReset()
        paymentSystemResolverMock.fullReset()
        bankResolverMock.fullReset()
    }
}
