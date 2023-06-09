//
//  MainFormOrderDetailsViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 09.06.2023.
//

final class MainFormOrderDetailsViewPresenterAssembly: IMainFormOrderDetailsViewPresenterAssembly {

    // MARK: Dependencies

    private let moneyFormatter: IMoneyFormatter

    // MARK: Initialization

    init(moneyFormatter: IMoneyFormatter) {
        self.moneyFormatter = moneyFormatter
    }

    // MARK: IMainFormOrderDetailsViewPresenterAssembly

    func build(amount: Int64, orderDescription: String?) -> any IMainFormOrderDetailsViewOutput {
        MainFormOrderDetailsViewPresenter(
            moneyFormatter: moneyFormatter,
            amount: amount,
            orderDescription: orderDescription
        )
    }
}
