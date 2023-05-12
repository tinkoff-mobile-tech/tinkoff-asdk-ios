//
//  SavedCardViewPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 24.01.2023.
//

import Foundation
import TinkoffASDKCore

final class SavedCardViewPresenter: ISavedCardViewOutput, ISavedCardViewPresenterInput {
    // MARK: ISavedCardViewPresenterInput Properties

    var presentationState: SavedCardPresentationState = .idle {
        didSet {
            guard presentationState != oldValue else { return }
            resetInternalState()
            setupView()
        }
    }

    var isValid: Bool {
        validator.validate(inputCVC: cvcInputText)
    }

    var cardId: String? {
        switch presentationState {
        case let .selected(card, _): return card.cardId
        default: return nil
        }
    }

    var cvc: String? {
        isValid ? cvcInputText : nil
    }

    // MARK: ISavedCardViewOutput Properties

    weak var view: ISavedCardViewInput? {
        didSet {
            setupView()
        }
    }

    // MARK: Dependencies

    private let validator: ICardRequisitesValidator
    private let paymentSystemResolver: IPaymentSystemResolver
    private let bankResolver: IBankResolver
    private weak var output: ISavedCardViewPresenterOutput?

    // MARK: State

    private var hasUserInteractedWithCVC = false
    private var shouldActivateOnSetup = false
    private var cvcInputText = "" {
        didSet {
            guard cvcInputText != oldValue else { return }
            output?.savedCardPresenter(self, didUpdateCVC: cvcInputText, isValid: isValid)
        }
    }

    // MARK: Init

    init(
        validator: ICardRequisitesValidator = CardRequisitesValidator(),
        paymentSystemResolver: IPaymentSystemResolver = PaymentSystemResolver(),
        bankResolver: IBankResolver = BankResolver(),
        output: ISavedCardViewPresenterOutput
    ) {
        self.validator = validator
        self.paymentSystemResolver = paymentSystemResolver
        self.bankResolver = bankResolver
        self.output = output
    }

    // MARK: ISavedCardViewPresenterInput

    func activateCVCField() {
        view?.activateCVCField()
        shouldActivateOnSetup = view == nil
    }

    // MARK: View Reloading

    private func setupView() {
        shouldActivateOnSetup ? view?.activateCVCField() : view?.deactivateCVCField()
        shouldActivateOnSetup = false

        switch presentationState {
        case let .selected(card, showChangeDescription):
            let viewModel = createViewModel(card: card, showChangeDescription: showChangeDescription)
            view?.update(with: viewModel)
            view?.showCVCField()
            view?.setCVCText(cvcInputText)
            updateCVCFieldValidationState()
        case .idle:
            view?.update(with: SavedCardViewModel())
            view?.hideCVCField()
        }
    }

    private func resetInternalState() {
        hasUserInteractedWithCVC = false
        cvcInputText = ""
    }

    // MARK: View Models Creation

    private func createViewModel(card: PaymentCard, showChangeDescription: Bool) -> SavedCardViewModel {
        let bank = bankResolver.resolve(cardNumber: card.pan).getBank()
        let paymentSystem = paymentSystemResolver.resolve(by: card.pan).getPaymentSystem()

        let iconModel = DynamicIconCardView.Model(
            data: DynamicIconCardView.Data(bank: bank?.icon, paymentSystem: paymentSystem?.icon)
        )

        return SavedCardViewModel(
            iconModel: iconModel,
            cardName: .formatCardName(bankName: bank?.naming, pan: card.pan),
            actionDescription: showChangeDescription ? Loc.Acquiring.PaymentCard.changeButton : nil
        )
    }

    private func updateCVCFieldValidationState() {
        let shouldShowValidState = !hasUserInteractedWithCVC || isValid
        shouldShowValidState ? view?.setCVCFieldValid() : view?.setCVCFieldInvalid()
    }
}

// MARK: - ISavedCardViewOutput Methods

extension SavedCardViewPresenter {
    func savedCardView(didChangeCVC cvcInputText: String) {
        guard self.cvcInputText != cvcInputText else { return }

        self.cvcInputText = cvcInputText
        updateCVCFieldValidationState()

        output?.savedCardPresenter(self, didUpdateCVC: cvcInputText, isValid: isValid)
    }

    func savedCardViewDidBeginCVCFieldEditing() {
        hasUserInteractedWithCVC = true
        updateCVCFieldValidationState()
    }

    func savedCardViewIsSelected() {
        view?.deactivateCVCField()

        switch presentationState {
        case let .selected(card, showChangeDescription) where showChangeDescription:
            output?.savedCardPresenter(self, didRequestReplacementFor: card)
        case .selected, .idle:
            break
        }
    }
}

// MARK: - Constants

private extension Int {
    static let panSuffixCount = 4
}

// MARK: - Helpers

private extension String {
    static func formatCardName(bankName: String?, pan: String) -> String {
        guard pan.count >= .panSuffixCount else { return "" }

        return [bankName, "•", String(pan.suffix(.panSuffixCount))]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
