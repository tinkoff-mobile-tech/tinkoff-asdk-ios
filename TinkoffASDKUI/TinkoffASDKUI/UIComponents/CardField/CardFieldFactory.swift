//
//  CardFieldFactory.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

import Foundation

protocol ICardFieldFactory {
    func assembleCardFieldView() -> CardFieldView
}

final class CardFieldFactory: ICardFieldFactory {
    func assembleCardFieldView() -> CardFieldView {
        let presenter = CardFieldPresenter()

        let maskingFactory = CardFieldMaskingFactory()
        let view = CardFieldView(presenter: presenter, maskingFactory: maskingFactory)
        presenter.view = view

        presenter.validationResultDidChange = { [weak view] result in
            view?.delegate?.cardFieldValidationResultDidChange(result: result)
        }

        return view
    }
}
