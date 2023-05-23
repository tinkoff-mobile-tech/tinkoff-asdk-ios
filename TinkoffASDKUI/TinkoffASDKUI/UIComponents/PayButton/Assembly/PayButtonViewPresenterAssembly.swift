//
//  PayButtonViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

final class PayButtonViewPresenterAssembly: IPayButtonViewPresenterAssembly {
    // MARK: Dependencies

    private let moneyFormatter: IMoneyFormatter

    // MARK: Initialization

    init(moneyFormatter: IMoneyFormatter) {
        self.moneyFormatter = moneyFormatter
    }

    // MARK: ICardFieldPresenterAssembly

    func build(
        presentationState: PayButtonViewPresentationState,
        output: IPayButtonViewPresenterOutput?
    ) -> IPayButtonViewOutput {
        PayButtonViewPresenter(
            presentationState: presentationState,
            moneyFormatter: moneyFormatter,
            output: output
        )
    }
}
