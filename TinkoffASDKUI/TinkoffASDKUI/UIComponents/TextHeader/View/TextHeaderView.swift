//
//  TextHeaderView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

typealias TextHeaderTableCell = TableCell<TextHeaderView>

final class TextHeaderView: UIView {
    // MARK: Dependencies

    var presenter: ITextHeaderViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Subviews

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headingMedium
        label.textColor = ASDKColors.Text.primary.color
        return label
    }()

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
        addSubview(titleLabel)
        titleLabel.pinEdgesToSuperview()
    }
}

// MARK: - ITextHeaderViewInput

extension TextHeaderView: ITextHeaderViewInput {
    func set(title: String) {
        titleLabel.text = title
    }
}
