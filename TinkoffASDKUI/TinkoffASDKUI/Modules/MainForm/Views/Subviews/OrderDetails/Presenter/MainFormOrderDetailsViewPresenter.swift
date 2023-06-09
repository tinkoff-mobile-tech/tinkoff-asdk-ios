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

    init(moneyFormatter: IMoneyFormatter, amount: Int64, orderDescription: String?) {
        self.moneyFormatter = moneyFormatter
        self.amount = amount
        self.orderDescription = orderDescription
    }

    // MARK: IMainFormOrderDetailsViewOutput

    func copy() -> any IMainFormOrderDetailsViewOutput {
        MainFormOrderDetailsViewPresenter(moneyFormatter: moneyFormatter, amount: amount, orderDescription: orderDescription)
    }

    // MARK: View Reloading

    private func setupView() {
        view?.set(amountDescription: Loc.CommonSheet.PaymentForm.toPayTitle)
        view?.set(amount: moneyFormatter.formatAmount(Int(amount)))
        view?.set(orderDescription: orderDescription)
    }
}

// MARK: - Equatable

extension MainFormOrderDetailsViewPresenter {
    static func == (lhs: MainFormOrderDetailsViewPresenter, rhs: MainFormOrderDetailsViewPresenter) -> Bool {
        lhs.moneyFormatter === rhs.moneyFormatter &&
            lhs.amount == rhs.amount &&
            lhs.orderDescription == rhs.orderDescription
    }
}
