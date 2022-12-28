//
//  MockCardFieldFactory.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 28.12.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockCardFieldFactory: ICardFieldFactory {

    var assembleCardFieldConfigCallCounter = 0
    lazy var assembleCardFieldConfigStub: (@escaping () -> ICardFieldView?) -> CardFieldFactory.FactoryResult =
        { [unowned self] getCardFieldView in
            self.prepareFactoryResult(getCardFieldView: getCardFieldView)
        }

    func assembleCardFieldConfig(getCardFieldView: @escaping () -> ICardFieldView?) -> CardFieldFactory.FactoryResult {
        assembleCardFieldConfigCallCounter += 1
        return assembleCardFieldConfigStub(getCardFieldView)
    }
}

extension MockCardFieldFactory {

    private func prepareFactoryResult(getCardFieldView: @escaping () -> ICardFieldView?) -> CardFieldFactory.FactoryResult {
        return .init(
            configuration:
            .assembleWithRegularStyle(
                data: CardFieldView.DataDependecies(
                    dynamicCardIconData: DynamicIconCardView.Data(),
                    expirationTextFieldData: CardFieldView.DataDependecies.TextFieldData(
                        delegate: nil, text: nil, placeholder: nil, headerText: ""
                    ),
                    cardNumberTextFieldData: CardFieldView.DataDependecies.TextFieldData(
                        delegate: nil, text: nil, placeholder: nil, headerText: ""
                    ),
                    cvcTextFieldData: CardFieldView.DataDependecies.TextFieldData(
                        delegate: nil, text: nil, placeholder: nil, headerText: ""
                    )
                )
            ),
            presenter: CardFieldPresenter(getCardFieldView: getCardFieldView, listenerStorage: [])
        )
    }
}
