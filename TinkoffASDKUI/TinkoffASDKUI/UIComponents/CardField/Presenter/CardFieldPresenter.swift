//
//  CardFieldPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.02.2023.
//

import UIKit

final class CardFieldPresenter: ICardFieldViewOutput {
    weak var view: ICardFieldViewInput? {
        didSet {
            setupView()
        }
    }

    private weak var output: ICardFieldOutput?

    private(set) var validationResult = CardFieldValidationResult() {
        didSet {
            output?.cardFieldValidationResultDidChange(result: validationResult)
        }
    }

    private(set) var cardNumber: String = ""
    private(set) var expiration: String = ""
    private(set) var cvc: String = ""

    private var didEndEditingCardNumber = false
    private var didStartEditingExpiration = false
    private var didEndEditingExpiration = false
    private var didStartEditingCvc = false
    private var didEndEditingCvc = false

    private let validator: ICardRequisitesValidator
    private let paymentSystemResolver: IPaymentSystemResolver
    private let bankResolver: IBankResolver

    init(
        output: ICardFieldOutput,
        validator: ICardRequisitesValidator = CardRequisitesValidator(),
        paymentSystemResolver: IPaymentSystemResolver = PaymentSystemResolver(),
        bankResolver: IBankResolver = BankResolver()
    ) {
        self.output = output
        self.validator = validator
        self.paymentSystemResolver = paymentSystemResolver
        self.bankResolver = bankResolver
    }

    func didFillCardNumber(text: String, filled: Bool) {
        cardNumber = text
        validate()

        let bankResult = bankResolver.resolve(cardNumber: text)
            .getBank()?
            .icon

        let paymentSystemResult = paymentSystemResolver.resolve(by: text)
            .getPaymentSystem()?
            .icon

        var dynamicCardModel = createDynamicCardModel()
        dynamicCardModel.data.bank = bankResult
        dynamicCardModel.data.paymentSystem = paymentSystemResult
        view?.updateDynamicCardView(with: dynamicCardModel)

        if filled { view?.activate(textFieldType: .expiration) }
    }

    func didFillExpiration(text: String, filled: Bool) {
        expiration = text
        validate()

        if filled { view?.activate(textFieldType: .cvc) }
    }

    func didFillCvc(text: String, filled: Bool) {
        cvc = text
        validate()

        if filled { view?.deactivate() }
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

    @discardableResult
    func validateWholeForm() -> CardFieldValidationResult {
        let result = validate()
        viewUpdateHeadersIfNeeded(result: result)
        return result
    }

    // MARK: - Private

    private func setupView() {
        view?.updateDynamicCardView(with: createDynamicCardModel())
    }

    private func createDynamicCardModel() -> DynamicIconCardView.Model {
        DynamicIconCardView.Model(data: DynamicIconCardView.Data())
    }

    @discardableResult
    private func validate() -> CardFieldValidationResult {
        let result = CardFieldValidationResult(
            cardNumberIsValid: validator.validate(inputPAN: cardNumber),
            expirationIsValid: validator.validate(inputValidThru: expiration),
            cvcIsValid: validator.validate(inputCVC: cvc)
        )
        validationResult = result
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
        if didEndEditingCvc {
            return CardFieldType.allCases
        }

        if didStartEditingCvc || didEndEditingExpiration {
            return [.cardNumber, .expiration]
        }

        if didStartEditingExpiration || didEndEditingCardNumber {
            return [.cardNumber]
        }

        return []
    }
}
