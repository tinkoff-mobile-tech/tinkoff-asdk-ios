//
//  TableCell.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import UIKit

final class TableCell<ContainedView: UIView>: UITableViewCell {
    // MARK: Properties

    var insets: UIEdgeInsets = .zero {
        didSet {
            guard insets != oldValue else { return }
            insetsDidUpdate()
        }
    }

    // MARK: Subviews

    private(set) lazy var containedView = ContainedView()

    // MARK: Constraints

    private lazy var topConstraint = containedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top)
    private lazy var leadingConstraint = containedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left)
    private lazy var trailingConstraint = containedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right)
    private lazy var bottomConstraint = containedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom)

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupView() {
        selectionStyle = .none

        contentView.addSubview(containedView)
        containedView.translatesAutoresizingMaskIntoConstraints = false
        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            topConstraint,
            leadingConstraint,
            trailingConstraint,
            bottomConstraint,
        ])
    }

    // MARK: Events

    private func insetsDidUpdate() {
        topConstraint.constant = insets.top
        leadingConstraint.constant = insets.left
        trailingConstraint.constant = -insets.right
        bottomConstraint.constant = -insets.bottom
        setNeedsLayout()
    }
}
