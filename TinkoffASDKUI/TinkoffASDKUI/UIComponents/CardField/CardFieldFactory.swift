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
        let cardViewModel = DynamicIconCardView.Model(data: DynamicIconCardView.Data())
        let config = CardFieldViewConfig(dynamicCardIcon: cardViewModel)
        let presenter = CardFieldPresenter(config: config)

        let maskingFactory = CardFieldMaskingFactory()
        let view = CardFieldView(presenter: presenter, maskingFactory: maskingFactory)
        presenter.view = view

        presenter.validationResultDidChange = { [weak view] result in
            view?.delegate?.cardFieldValidationResultDidChange(result: result)
        }

        view.update(with: config)
        return view
    }
}
