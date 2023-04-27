//
//  PayButtonView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import UIKit

typealias PayButtonTableCell = TableCell<PayButtonView>

final class PayButtonView: UIView {
    // MARK: Internal Types

    enum Constants {
        static let minimalHeight = Button.ContentSize.basicLarge.preferredHeight
    }

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

    func set(enabled: Bool, animated: Bool) {
        if animated {
            button.isEnabled = enabled
        } else {
            UIView.performWithoutAnimation { self.button.isEnabled = enabled }
        }
    }

    func startLoading() {
        button.startLoading()
    }

    func stopLoading() {
        button.stopLoading()
    }
}
