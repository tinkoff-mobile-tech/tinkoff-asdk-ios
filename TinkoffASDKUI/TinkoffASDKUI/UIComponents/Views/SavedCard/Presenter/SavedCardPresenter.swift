//
//  SavedCardPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 24.01.2023.
//

import Foundation
import TinkoffASDKCore

final class SavedCardPresenter: ISavedCardViewOutput, ISavedCardPresenterInput {
    // MARK: ISavedCardPresenterInput Properties

    var presentationState: SavedCardPresentationState = .idle {
        didSet { presentationStateDidChange(from: oldValue, to: presentationState) }
    }

    var isValid: Bool {
        validator.validate(inputCVC: cvсInputText)
    }

    var cvc: String? {
        isValid ? cvсInputText : nil
    }

    // MARK: ISavedCardViewOutput Properties

    weak var view: ISavedCardViewInput? {
        didSet { reloadView() }
    }

    // MARK: Dependencies

    private let validator: ICardRequisitesValidator
    private let paymentSystemResolver: IPaymentSystemResolver
    private let bankResolver: IBankResolver
    private weak var output: ISavedCardPresenterOutput?

    // MARK: State

    private var hasUserInteractedWithCVC = false
    private var cvсInputText = "" {
        didSet { cvcInputTextDidChange(from: oldValue, to: cvсInputText) }
    }

    // MARK: Init

    init(
        validator: ICardRequisitesValidator = CardRequisitesValidator(),
        paymentSystemResolver: IPaymentSystemResolver = PaymentSystemResolver(),
        bankResolver: IBankResolver = BankResolver(),
        output: ISavedCardPresenterOutput
    ) {
        self.validator = validator
        self.paymentSystemResolver = paymentSystemResolver
        self.bankResolver = bankResolver
        self.output = output
    }

    // MARK: View Reloading

    private func reloadView() {
        let viewModel: SavedCardViewModel

        switch presentationState {
        case .idle:
            viewModel = createIdleViewModel()
        case let .selected(card, hasAnotherCards):
            viewModel = createSelectedViewModel(card: card, hasAnotherCards: hasAnotherCards)
        }

        view?.update(with: viewModel)
    }

    // MARK: Property Events

    private func presentationStateDidChange(
        from oldValue: SavedCardPresentationState,
        to newValue: SavedCardPresentationState
    ) {
        hasUserInteractedWithCVC = false
        cvсInputText = ""
        reloadView()
    }

    private func cvcInputTextDidChange(from oldValue: String, to newValue: String) {
        guard oldValue != newValue else { return }
        output?.savedCardPresenter(self, didUpdateCVC: newValue, isValid: isValid)
    }

    // MARK: View Models Creation

    private func createIdleViewModel() -> SavedCardViewModel {
        SavedCardViewModel(
            iconModel: DynamicIconCardView.Model(data: DynamicIconCardView.Data()),
            cardName: "",
            actionDescription: nil,
            cvcField: nil
        )
    }

    private func createSelectedViewModel(card: PaymentCard, hasAnotherCards: Bool) -> SavedCardViewModel {
        let bank = bankResolver.resolve(cardNumber: card.pan).getBank()
        let paymentSystem = paymentSystemResolver.resolve(by: card.pan).getPaymentSystem()

        let iconModel = DynamicIconCardView.Model(
            data: DynamicIconCardView.Data(bank: bank?.icon, paymentSystem: paymentSystem?.icon)
        )

        let cvcModel = SavedCardViewModel.CVCField(
            text: cvсInputText,
            isValid: hasUserInteractedWithCVC ? isValid : true
        )

        return SavedCardViewModel(
            iconModel: iconModel,
            cardName: .formatCardName(bankName: bank?.naming, pan: card.pan),
            actionDescription: hasAnotherCards ? "Сменить карту" : nil,
            cvcField: cvcModel
        )
    }
}

// MARK: - ISavedCardViewOutput Methods

extension SavedCardPresenter {
    func cvcField(didFillWith text: String) {
        cvсInputText = text
        reloadView()

        if isValid {
            view?.deactivateCVCField()
        }
    }

    func cvcFieldDidBeginEditing() {
        hasUserInteractedWithCVC = true
        reloadView()
    }

    func didSelectView() {
        switch presentationState {
        case let .selected(card, hasAnotherCards) where hasAnotherCards:
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
