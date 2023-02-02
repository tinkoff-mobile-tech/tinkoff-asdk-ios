//
//  CardFieldPresenter.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 29.11.2022.
//

import UIKit

enum CardFieldType: CaseIterable {
    case cardNumber
    case expiration
    case cvc
}

protocol ICardFieldView: AnyObject, Activatable {
    func setHeaderErrorFor(textFieldType: CardFieldType)
    func setHeaderNormalFor(textFieldType: CardFieldType)

    func activateExpirationField()
    func activateCvcField()
}

protocol ICardFieldInput: AnyObject {
    var cardNumber: String { get }
    var expiration: String { get }
    var cvc: String { get }

    var validationResult: CardFieldValidationResult { get }

    @discardableResult
    func validateWholeForm() -> CardFieldValidationResult
}

protocol ICardFieldPresenter: ICardFieldInput {
    var config: CardFieldView.Config? { get set }
    var validationResultDidChange: ((CardFieldValidationResult) -> Void)? { get set }

    func didFillCardNumber(text: String, filled: Bool)
    func didFillExpiration(text: String, filled: Bool)
    func didFillCvc(text: String, filled: Bool)

    func didBeginEditing(fieldType: CardFieldType)
    func didEndEditing(fieldType: CardFieldType)
}

final class CardFieldPresenter: ICardFieldPresenter {

    var config: CardFieldView.Config?
    var validationResultDidChange: ((CardFieldValidationResult) -> Void)?

    weak var view: ICardFieldView?

    private(set) var validationResult: CardFieldValidationResult {
        didSet { validationResultDidChange?(validationResult) }
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

    // Хранит listener-ы для masked text field delegate
    private var listenerStorage: [NSObject]

    init(
        listenerStorage: [NSObject],
        config: CardFieldView.Config? = nil,
        validator: ICardRequisitesValidator = CardRequisitesValidator(),
        paymentSystemResolver: IPaymentSystemResolver = PaymentSystemResolver(),
        bankResolver: IBankResolver = BankResolver()
    ) {
        self.listenerStorage = listenerStorage
        self.config = config
        self.validator = validator
        self.paymentSystemResolver = paymentSystemResolver
        self.bankResolver = bankResolver
        validationResult = CardFieldValidationResult()
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

        config?.dynamicCardIcon.data.bank = bankResult
        config?.dynamicCardIcon.data.paymentSystem = paymentSystemResult

        if let dynamicCardConfig = config?.dynamicCardIcon {
            config?.dynamicCardIcon.updater?.update(config: dynamicCardConfig)
        }

        if filled { view?.activateExpirationField() }
    }

    func didFillExpiration(text: String, filled: Bool) {
        expiration = text
        validate()

        if filled { view?.activateCvcField() }
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
