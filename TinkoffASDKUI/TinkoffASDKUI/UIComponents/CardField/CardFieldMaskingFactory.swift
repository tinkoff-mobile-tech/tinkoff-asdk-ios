//
//  CardFieldMaskingFactory.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import UIKit

protocol ICardFieldMaskingFactory {
    typealias DidFillMask = (_ value: String, _ completed: Bool) -> Void

    /// Готовит делегат текстфилда для поля - номер карты
    /// - Parameters:
    ///   - didFillMask: Событие редактирования поля
    ///   - listenerStorage: Хранит сильной ссылкой listener событий для делегата
    /// - Returns: Делегат маскированного текст филда
    func buildForCardNumber(didFillMask: DidFillMask?, listenerStorage: inout [NSObject]) -> MaskedTextFieldDelegate

    /// Готовит делегат текстфилда для поля - срок
    /// - Parameters:
    ///   - didFillMask: Событие редактирования поля
    ///   - listenerStorage: Хранит сильной ссылкой listener событий для делегата
    /// - Returns: Делегат маскированного текст филда
    func buildForExpiration(didFillMask: DidFillMask?, listenerStorage: inout [NSObject]) -> MaskedTextFieldDelegate

    /// Готовит делегат текстфилда для поля - cvc
    /// - Parameters:
    ///   - didFillMask: Событие редактирования поля
    ///   - listenerStorage: Хранит сильной ссылкой listener событий для делегата
    /// - Returns: Делегат маскированного текст филда
    func buildForCvc(didFillMask: DidFillMask?, listenerStorage: inout [NSObject]) -> MaskedTextFieldDelegate
}

final class CardFieldMaskingFactory: ICardFieldMaskingFactory {

    private let inputMaskResolver: ICardRequisitesMasksResolver
    private let paymentSystemResolver: IPaymentSystemResolver

    // MARK: - Inits

    init() {
        paymentSystemResolver = PaymentSystemResolver()
        inputMaskResolver = CardRequisitesMasksResolver(paymentSystemResolver: paymentSystemResolver)
    }

    init(
        inputMaskResolver: ICardRequisitesMasksResolver,
        paymentSystemResolver: IPaymentSystemResolver
    ) {
        self.paymentSystemResolver = paymentSystemResolver
        self.inputMaskResolver = inputMaskResolver
    }

    // MARK: - ICardFieldMaskingFactory

    func buildForCardNumber(didFillMask: DidFillMask?, listenerStorage: inout [NSObject]) -> MaskedTextFieldDelegate {
        let listener = CardNumberListener()
        let delegate = MaskedTextFieldDelegate(format: inputMaskResolver.panMask(for: nil))
        listenerStorage.append(listener)
        delegate.listener = listener
        listener.didFill = { [inputMaskResolver] text, completed, textField in
            let updated = delegate.update(
                maskFormat: inputMaskResolver.panMask(for: text),
                using: textField
            )

            if updated {
                return
            } else {
                didFillMask?(text, completed)
            }
        }
        return delegate
    }

    func buildForExpiration(didFillMask: DidFillMask?, listenerStorage: inout [NSObject]) -> MaskedTextFieldDelegate {
        let listener = ExpirationListener()
        let delegate = MaskedTextFieldDelegate(format: inputMaskResolver.validThruMask)
        listenerStorage.append(listener)
        delegate.listener = listener
        listener.didFill = didFillMask
        return delegate
    }

    func buildForCvc(didFillMask: DidFillMask?, listenerStorage: inout [NSObject]) -> MaskedTextFieldDelegate {
        let listener = CvcListener()
        let delegate = MaskedTextFieldDelegate(format: inputMaskResolver.cvcMask)
        listenerStorage.append(listener)
        delegate.listener = listener
        listener.didFill = didFillMask
        return delegate
    }
}

extension CardFieldMaskingFactory {

    final class CardNumberListener: NSObject, MaskedTextFieldDelegateListener {
        var didFill: ((String, Bool, UITextField) -> Void)?

        func textField(_ textField: UITextField, didFillMask complete: Bool, extractValue value: String) {
            didFill?(value, complete, textField)
        }
    }

    final class ExpirationListener: NSObject, MaskedTextFieldDelegateListener {
        var didFill: DidFillMask?

        func textField(_ textField: UITextField, didFillMask complete: Bool, extractValue value: String) {
            didFill?(value, complete)
        }
    }

    final class CvcListener: NSObject, MaskedTextFieldDelegateListener {
        var didFill: DidFillMask?

        func textField(_ textField: UITextField, didFillMask complete: Bool, extractValue value: String) {
            didFill?(value, complete)
        }
    }
}
