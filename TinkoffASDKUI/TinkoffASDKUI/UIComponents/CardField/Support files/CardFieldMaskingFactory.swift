//
//  CardFieldMaskingFactory.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import UIKit

final class CardFieldMaskingFactory: ICardFieldMaskingFactory {

    // MARK: Dependencies

    private let inputMaskResolver: ICardRequisitesMasksResolver

    // MARK: Initialization

    init(inputMaskResolver: ICardRequisitesMasksResolver = CardRequisitesMasksResolver(paymentSystemResolver: PaymentSystemResolver())) {
        self.inputMaskResolver = inputMaskResolver
    }
}

// MARK: - ICardFieldMaskingFactory

extension CardFieldMaskingFactory {
    func buildMaskingDelegate(for fieldType: CardFieldType, listener: MaskedTextFieldDelegateListener) -> MaskedTextFieldDelegate {
        let delegate: MaskedTextFieldDelegate

        switch fieldType {
        case .cardNumber: delegate = MaskedTextFieldDelegate(format: inputMaskResolver.panMask(for: nil))
        case .expiration: delegate = MaskedTextFieldDelegate(format: inputMaskResolver.validThruMask)
        case .cvc: delegate = MaskedTextFieldDelegate(format: inputMaskResolver.cvcMask)
        }

        delegate.listener = listener
        return delegate
    }
}
