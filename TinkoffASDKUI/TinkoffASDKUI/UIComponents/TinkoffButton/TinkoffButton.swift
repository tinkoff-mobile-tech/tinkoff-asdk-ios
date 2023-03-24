//
//  TinkoffButton.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.03.2023.
//

import UIKit

public final class TinkoffButton: UIView {

    // MARK: Properties

    public var actionClosure: (() -> Void)?

    private lazy var button: Button = {
        let config = Button.Configuration(
            title: Loc.CommonSheet.PaymentForm.tinkoffPayPrimaryButton,
            image: Asset.TinkoffPay.tinkoffPaySmallNoBorder.image,
            style: .primaryTinkoff,
            contentSize: .basicLarge,
            imagePlacement: .trailing
        )

        let button = Button(configuration: config, action: { [weak self] in self?.actionClosure?() })
        return button
    }()

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private

extension TinkoffButton {
    private func setupViews() {
        backgroundColor = .clear
        addSubview(button)
    }

    private func setupConstraints() {
        button.makeEqualToSuperview()
    }
}
