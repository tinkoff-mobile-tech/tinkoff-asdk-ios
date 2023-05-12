//
//  MainFormOrderDetailsViewPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

final class MainFormOrderDetailsViewPresenter: IMainFormOrderDetailsViewOutput {
    // MARK: IMainFormOrderDetailsViewOutput Properties

    weak var view: IMainFormOrderDetailsViewInput? {
        didSet { setupView() }
    }

    // MARK: Dependencies

    private let moneyFormatter: IMoneyFormatter
    private let amount: Int64
    private let orderDescription: String?

    // MARK: Init

    init(moneyFormatter: IMoneyFormatter = MoneyFormatter(), amount: Int64, orderDescription: String?) {
        self.moneyFormatter = moneyFormatter
        self.amount = amount
        self.orderDescription = orderDescription
    }

    // MARK: IMainFormOrderDetailsViewOutput

    func copy() -> IMainFormOrderDetailsViewOutput {
        MainFormOrderDetailsViewPresenter(moneyFormatter: moneyFormatter, amount: amount, orderDescription: orderDescription)
    }

    // MARK: View Reloading

    private func setupView() {
        view?.set(amountDescription: Loc.CommonSheet.PaymentForm.toPayTitle)
        view?.set(amount: moneyFormatter.formatAmount(Int(amount)))
        view?.set(orderDescription: orderDescription)
    }
}
