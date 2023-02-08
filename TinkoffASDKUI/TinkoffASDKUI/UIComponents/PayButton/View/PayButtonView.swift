//
//  PayButtonView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import UIKit

final class PayButtonView: UIView {
    // MARK: Dependencies

    var presenter: IPayButtonViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Subviews

    private lazy var button = Button(
        configuration: Button.Configuration(style: .primaryTinkoff, contentSize: .basicLarge),
        action: { [weak self] in self?.presenter?.payButtonTapped() }
    )

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(button)
        button.pinEdgesToSuperview()
    }
}

// MARK: - IPayButtonViewInput

extension PayButtonView: IPayButtonViewInput {
    func set(configuration: Button.Configuration) {
        button.configure(configuration)
    }

    func set(enabled: Bool) {
        button.isEnabled = enabled
    }

    func startLoading() {
        button.startLoading()
    }

    func stopLoading() {
        button.stopLoading()
    }
}
