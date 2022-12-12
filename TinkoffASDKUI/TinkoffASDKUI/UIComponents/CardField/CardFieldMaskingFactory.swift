//
//  CardFieldMaskingFactory.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import UIKit

protocol ICardFieldMaskingFactory {
    typealias DidFillMask = (_ value: String, _ completed: Bool) -> Void

    func buildForCardNumber(didFillMask: DidFillMask?) -> MaskedTextFieldDelegate
    func buildForExpiration(didFillMask: DidFillMask?) -> MaskedTextFieldDelegate
    func buildForCvc(didFillMask: DidFillMask?) -> MaskedTextFieldDelegate
}

final class CardFieldMaskingFactory: ICardFieldMaskingFactory {

    private let inputMaskResolver: ICardRequisitesMasksResolver
    private let paymentSystemResolver: IPaymentSystemResolver

    private var listenerStorage: [NSObject] = []

    // MARK: - Inits

    init() {
        let paymentSystemResolver = PaymentSystemResolver()
        inputMaskResolver = CardRequisitesMasksResolver(paymentSystemResolver: paymentSystemResolver
        )
        self.paymentSystemResolver = paymentSystemResolver
    }

    init(
        inputMaskResolver: ICardRequisitesMasksResolver,
        paymentSystemResolver: IPaymentSystemResolver
    ) {
        self.paymentSystemResolver = paymentSystemResolver
        self.inputMaskResolver = inputMaskResolver
    }

    // MARK: - ICardFieldMaskingFactory

    func buildForCardNumber(didFillMask: DidFillMask?) -> MaskedTextFieldDelegate {
        let listener = CardNumberListener()
        let delegate = MaskedTextFieldDelegate(format: inputMaskResolver.panMask(for: nil))
        listenerStorage.append(listener)
        delegate.listener = listener
        listener.didFill = { [weak self] text, completed, textField in
            guard let self = self else { return }
            let updated = delegate.update(
                maskFormat: self.inputMaskResolver.panMask(for: text),
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

    func buildForExpiration(didFillMask: DidFillMask?) -> MaskedTextFieldDelegate {
        let listener = ExpirationListener()
        let delegate = MaskedTextFieldDelegate(format: inputMaskResolver.validThruMask)
        listenerStorage.append(listener)
        delegate.listener = listener
        listener.didFill = didFillMask
        return delegate
    }

    func buildForCvc(didFillMask: DidFillMask?) -> MaskedTextFieldDelegate {
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
