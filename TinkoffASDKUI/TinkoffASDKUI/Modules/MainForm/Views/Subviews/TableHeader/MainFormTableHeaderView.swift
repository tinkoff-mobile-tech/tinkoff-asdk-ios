//
//  MainFormTableHeaderView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import UIKit

final class MainFormTableHeaderView: UIView {
    // MARK: Subviews

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: Asset.Logo.smallGerb.image)
        imageView.contentMode = .left
        return imageView
    }()

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
        addSubview(logoImageView)
        logoImageView.pinEdgesToSuperview(insets: UIEdgeInsets(horizontal: .commonHorizontalInsets))
    }
}

// MARK: - Constants

private extension CGFloat {
    static let commonHorizontalInsets: CGFloat = 16
}
