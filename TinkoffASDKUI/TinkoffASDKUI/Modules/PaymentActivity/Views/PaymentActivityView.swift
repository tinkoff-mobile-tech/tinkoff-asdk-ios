//
//  PaymentActivityView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 14.12.2022.
//

import UIKit

protocol PaymentActivityViewDelegate: AnyObject {
    func paymentActivityView(
        _ paymentActivityView: PaymentActivityView,
        didChangeStateFrom oldState: PaymentActivityViewState,
        to newState: PaymentActivityViewState
    )

    func paymentActivityView(
        _ paymentActivityView: PaymentActivityView,
        didTapPrimaryButtonWithState state: PaymentActivityViewState
    )
}

final class PaymentActivityView: UIView {
    weak var delegate: PaymentActivityViewDelegate?
    private(set) var state: PaymentActivityViewState = .idle

    // MARK: Subviews

    private lazy var processingView = PaymentActivityProcessingView()
    private lazy var processedView = PaymentActivityProcessedView(delegate: self)

    private lazy var overlayView: UIView = {
        let view = PassthroughView()
        view.backgroundColor = ASDKColors.Background.elevation1.color
        view.alpha = .zero
        return view
    }()

    // MARK: Constraints

    private lazy var processingViewConstraints: [NSLayoutConstraint] = [
        processingView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .commonTopInset),
        processingView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .processingHorizontalInset),
        processingView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.processingHorizontalInset),
        processingView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -.commonBottomInset)
            .with(priority: .fittingSizeLevel),
    ]

    private lazy var processedViewConstraints: [NSLayoutConstraint] = [
        processedView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .commonTopInset),
        processedView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .processedHorizontalInset),
        processedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.processedHorizontalInset),
        processedView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -.commonBottomInset)
            .with(priority: .fittingSizeLevel),
    ]

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    convenience init(delegate: PaymentActivityViewDelegate) {
        self.init(frame: .zero)
        self.delegate = delegate
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Parent Methods

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayView.frame = bounds
    }

    // MARK: View Updating

    func update(with state: PaymentActivityViewState, animated: Bool = true) {
        guard self.state != state else { return }

        let oldState = self.state
        self.state = state

        showOverlay { [self] _ in
            switch state {
            case .idle:
                NSLayoutConstraint.deactivate(processingViewConstraints)
                processingView.removeFromSuperview()

                NSLayoutConstraint.deactivate(processedViewConstraints)
                processedView.removeFromSuperview()
            case let .processing(state):
                processingView.update(with: state)
                insertSubview(processingView, belowSubview: overlayView)
                NSLayoutConstraint.activate(processingViewConstraints)

                NSLayoutConstraint.deactivate(processedViewConstraints)
                processedView.removeFromSuperview()
            case let .processed(state):
                NSLayoutConstraint.deactivate(processingViewConstraints)
                processingView.removeFromSuperview()

                processedView.update(with: state)
                insertSubview(processedView, belowSubview: overlayView)
                NSLayoutConstraint.activate(processedViewConstraints)
            }

            DispatchQueue.main.async {
                self.delegate?.paymentActivityView(self, didChangeStateFrom: oldState, to: state)
            }

            hideOverlay()
        }
    }

    // MARK: Initial Configuration

    private func setupView() {
        processingView.translatesAutoresizingMaskIntoConstraints = false
        processedView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)
    }

    // MARK: - Overlay Animation

    private func showOverlay(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: .animationDuration,
            delay: .zero,
            options: [.curveEaseIn],
            animations: { self.overlayView.alpha = 1 },
            completion: completion
        )
    }

    private func hideOverlay(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: .animationDuration,
            delay: .zero,
            options: [.curveEaseOut],
            animations: { self.overlayView.alpha = .zero },
            completion: completion
        )
    }
}

// MARK: - PaymentActivityLoadedViewDelegate

extension PaymentActivityView: PaymentActivityProcessedViewDelegate {
    func paymentActivityProcessedViewDidTapPrimaryButton(_ view: PaymentActivityProcessedView) {
        delegate?.paymentActivityView(self, didTapPrimaryButtonWithState: state)
    }
}

// MARK: - PaymentActivityView + Estimated Height

extension PaymentActivityView {
    var estimatedHeight: CGFloat {
        systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}

// MARK: - Constants

private extension CGFloat {
    static let commonTopInset: CGFloat = 24
    static let commonBottomInset: CGFloat = 24
    static let processedHorizontalInset: CGFloat = 16
    static let processingHorizontalInset: CGFloat = 23.5
}

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.4
}
