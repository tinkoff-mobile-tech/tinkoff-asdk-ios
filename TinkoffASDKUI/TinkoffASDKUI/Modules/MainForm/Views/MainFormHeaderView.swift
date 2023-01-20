//
//  MainFormHeaderView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

final class MainFormHeaderView: UIView {
    // MARK: Subviews

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = .zero
        return stack
    }()

    private lazy var activityIndicatorContainer = ContainerView(ActivityIndicatorView(style: .xlYellow))

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.Logo.smallGerb.image)
        imageView.contentMode = .left
        return imageView
    }()

    private lazy var orderDetailsContainer = ContainerView(MainFormOrderDetailsView())
    private lazy var payButton = Button()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStubContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupView() {
        contentStack.addArrangedSubviews(logoImageView, orderDetailsContainer)
        layoutContentStack()
        layoutOrderDetails()
    }

    private func layoutContentStack() {
        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .commonHorizontalInsets),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.commonHorizontalInsets),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.contentStackBottomInset).with(priority: .fittingSizeLevel),
        ])
    }

    private func layoutActivityIndicator() {
        let subview = activityIndicatorContainer.content
        let superview = activityIndicatorContainer

        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            subview.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
            subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: .indicatorVerticalInsets),
            subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -.indicatorVerticalInsets),
        ])
    }

    private func layoutOrderDetails() {
        let subview = orderDetailsContainer.content
        let superview = orderDetailsContainer

        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: .orderDetailsVerticalInsets),
            subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -.orderDetailsVerticalInsets),
        ])
    }

    private func setupStubContent() {
        orderDetailsContainer.content.update(
            amountDescription: "К оплате",
            amount: "10 500 ₽",
            orderDescription: "Заказ №123456"
        )
    }
}

// MARK: - MainFormHeaderView + Estimated Height

extension MainFormHeaderView {
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
    static let indicatorVerticalInsets: CGFloat = 32
    static let commonHorizontalInsets: CGFloat = 16
    static let contentStackBottomInset: CGFloat = 36
    static let orderDetailsVerticalInsets: CGFloat = 32
}

// MARK: ContainerView Helper

private final class ContainerView<Content: UIView>: UIView {
    // MARK: Dependencies

    let content: Content

    // MARK: Init

    init(_ content: Content) {
        self.content = content
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
    }
}
