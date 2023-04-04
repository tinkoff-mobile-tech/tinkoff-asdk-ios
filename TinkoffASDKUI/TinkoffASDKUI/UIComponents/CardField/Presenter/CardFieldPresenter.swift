//
//  CardFieldPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

import UIKit

final class CardFieldPresenter: ICardFieldViewOutput {

    // MARK: Dependencies

    weak var view: ICardFieldViewInput? {
        didSet {
            setupView()
        }
    }

    private weak var output: ICardFieldOutput?

    private let validator: ICardRequisitesValidator
    private let paymentSystemResolver: IPaymentSystemResolver
    private let bankResolver: IBankResolver
    private let inputMaskResolver: ICardRequisitesMasksResolver

    // MARK: Properties

    var cardData: CardData { CardData(cardNumber: cardNumber, expiration: expiration, cvc: cvc) }

    private(set) var validationResult = CardFieldValidationResult()

    private(set) var cardNumber: String = ""
    private(set) var expiration: String = ""
    private(set) var cvc: String = ""

    private let isScanButtonNeeded: Bool

    private var didEndEditingCardNumber = false
    private var didStartEditingExpiration = false
    private var didEndEditingExpiration = false
    private var didStartEditingCvc = false
    private var didEndEditingCvc = false

    // MARK: Initialization

    init(
        output: ICardFieldOutput,
        isScanButtonNeeded: Bool,
        validator: ICardRequisitesValidator = CardRequisitesValidator(),
        paymentSystemResolver: IPaymentSystemResolver = PaymentSystemResolver(),
        bankResolver: IBankResolver = BankResolver(),
        inputMaskResolver: ICardRequisitesMasksResolver = CardRequisitesMasksResolver(paymentSystemResolver: PaymentSystemResolver())
    ) {
        self.output = output
        self.isScanButtonNeeded = isScanButtonNeeded
        self.validator = validator
        self.paymentSystemResolver = paymentSystemResolver
        self.bankResolver = bankResolver
        self.inputMaskResolver = inputMaskResolver
    }
}

// MARK: - ICardFieldInput

extension CardFieldPresenter {
    @discardableResult
    func validateWholeForm() -> CardFieldValidationResult {
        let result = validate()
        viewUpdateHeadersIfNeeded(result: result)
        return result
    }

    func set(textFieldType: CardFieldType, text: String?) {
        view?.set(textFieldType: textFieldType, text: text)
    }
}

// MARK: - ICardFieldViewOutput

extension CardFieldPresenter {
    func scanButtonPressed() {
        output?.scanButtonPressed()
    }

    func didFillField(type: CardFieldType, text: String, filled: Bool) {
        switch type {
        case .cardNumber:
            let maskFormat = inputMaskResolver.panMask(for: text)
            let isUpdated = view?.updateCardNumberField(with: maskFormat) ?? false
            if !isUpdated || text.isEmpty {
                didFillCardNumber(text: text, filled: filled)
            }
        case .expiration: didFillExpiration(text: text, filled: filled)
        case .cvc: didFillCvc(text: text, filled: filled)
        }
    }

    func didBeginEditing(fieldType: CardFieldType) {
        switch fieldType {
        case .cardNumber: break
        case .expiration: didStartEditingExpiration = true
        case .cvc: didStartEditingCvc = true
        }

        let result = validate()
        viewUpdateHeadersIfNeeded(result: result)
        clearVisualErrorState(for: fieldType)
    }

    func didEndEditing(fieldType: CardFieldType) {
        switch fieldType {
        case .cardNumber: didEndEditingCardNumber = true
        case .expiration: didEndEditingExpiration = true
        case .cvc: didEndEditingCvc = true
        }

        validate()
    }
}

// MARK: - Private

extension CardFieldPresenter {
    private func setupView() {
        view?.updateDynamicCardView(with: createDynamicCardModel())
        if isScanButtonNeeded {
            view?.activateScanButton()
            validateScanButtonState()
        }
    }

    private func createDynamicCardModel() -> DynamicIconCardView.Model {
        DynamicIconCardView.Model(data: DynamicIconCardView.Data())
    }

    private func didFillCardNumber(text: String, filled: Bool) {
        cardNumber = text
        validate()
        validateScanButtonState()

        var dynamicCardModel = createDynamicCardModel()
        dynamicCardModel.data.bank = bankResolver.resolve(cardNumber: text).getBank()?.icon
        dynamicCardModel.data.paymentSystem = paymentSystemResolver.resolve(by: text).getPaymentSystem()?.icon
        view?.updateDynamicCardView(with: dynamicCardModel)

        if filled { view?.activate(textFieldType: .expiration) }
    }

    private func didFillExpiration(text: String, filled: Bool) {
        expiration = text
        validate()

        if filled { view?.activate(textFieldType: .cvc) }
    }

    private func didFillCvc(text: String, filled: Bool) {
        cvc = text
        validate()

        if filled { view?.deactivate() }
    }

    @discardableResult
    private func validate() -> CardFieldValidationResult {
        let result = CardFieldValidationResult(
            cardNumberIsValid: validator.validate(inputPAN: cardNumber),
            expirationIsValid: validator.validate(inputValidThru: expiration),
            cvcIsValid: validator.validate(inputCVC: cvc)
        )
        validationResult = result
        output?.cardFieldValidationResultDidChange(result: validationResult)
        return result
    }

    private func viewUpdateHeader(fieldType: CardFieldType, isValid: Bool) {
        isValid ? view?.setHeaderNormalFor(textFieldType: fieldType) : view?.setHeaderErrorFor(textFieldType: fieldType)
    }

    private func viewUpdateHeadersIfNeeded(result: CardFieldValidationResult) {
        let fields = fieldsToValidate()
        fields.forEach { viewUpdateHeader(fieldType: $0, isValid: result.isFieldValid(type: $0)) }
    }

    private func clearVisualErrorState(for field: CardFieldType) {
        view?.setHeaderNormalFor(textFieldType: field)
    }

    private func fieldsToValidate() -> [CardFieldType] {
        if didEndEditingCvc { return CardFieldType.allCases }
        if didStartEditingCvc || didEndEditingExpiration { return [.cardNumber, .expiration] }
        if didStartEditingExpiration || didEndEditingCardNumber { return [.cardNumber] }

        return []
    }

    private func validateScanButtonState() {
        guard isScanButtonNeeded else { return }
        view?.setCardNumberTextField(rightViewMode: cardNumber.count > 0 ? .never : .unlessEditing)
    }
}
