//
//  PaymentActivityViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import UIKit

final class PaymentActivityViewController: UIViewController, PullableContainerContent {
    // MARK: PullableContainerContent Properties

    var pullableContainerContentHeight: CGFloat {
        paymentActivityView.estimatedHeight
    }

    var pullableContainerContentHeightDidChange: ((PullableContainerContent) -> Void)?

    // MARK: Dependencies

    private let presenter: IPaymentActivityViewOutput

    // MARK: UI

    private lazy var paymentActivityView = PaymentActivityView(delegate: self)

    // MARK: Init

    init(presenter: IPaymentActivityViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func loadView() {
        view = paymentActivityView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

// MARK: - IPaymentActivityViewInput

extension PaymentActivityViewController: IPaymentActivityViewInput {
    func update(with state: PaymentActivityViewState, animated: Bool) {
        paymentActivityView.update(with: state, animated: animated)
    }

    func close() {
        dismiss(animated: true, completion: presenter.viewWasClosed)
    }
}

// MARK: - PaymentActivityViewDelegate

extension PaymentActivityViewController: PaymentActivityViewDelegate {
    func paymentActivityView(
        _ paymentActivityView: PaymentActivityView,
        didChangeStateFrom oldState: PaymentActivityViewState,
        to newState: PaymentActivityViewState
    ) {
        pullableContainerContentHeightDidChange?(self)
    }

    func paymentActivityView(
        _ paymentActivityView: PaymentActivityView,
        didTapPrimaryButtonWithState state: PaymentActivityViewState
    ) {
        presenter.primaryButtonTapped()
    }
}

// MARK: - PullableContainerContent

extension PaymentActivityViewController {
    func pullableContainerWasClosed() {
        presenter.viewWasClosed()
    }

    func pullableContainerShouldDismissOnDownDragging() -> Bool {
        paymentActivityView.state.isDismissingAllowed
    }

    func pullableContainerShouldDismissOnDimmingViewTap() -> Bool {
        paymentActivityView.state.isDismissingAllowed
    }
}

// MARK: - PaymentActivityViewState + Helpers

private extension PaymentActivityViewState {
    var isDismissingAllowed: Bool {
        switch self {
        case .idle, .processed:
            return true
        case .processing:
            return false
        }
    }
}
