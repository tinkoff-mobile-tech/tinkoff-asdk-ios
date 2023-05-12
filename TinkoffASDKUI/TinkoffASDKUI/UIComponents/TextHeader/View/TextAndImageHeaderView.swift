//
//  TextAndImageHeaderView.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//
import UIKit

typealias TextAndImageHeaderTableCell = TableCell<TextAndImageHeaderView>

final class TextAndImageHeaderView: UIView {
    // MARK: Dependencies

    var presenter: ITextAndImageHeaderViewOutput? {
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

    private lazy var imageView = UIImageView()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupViews() {
        addSubview(titleLabel)
        addSubview(imageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            imageView.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: .imageViewOffset),
            imageView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor),
            imageView.widthAnchor.constraint(equalToConstant: .imageViewSide),
            imageView.heightAnchor.constraint(equalToConstant: .imageViewSide),
            imageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
    }
}

// MARK: - ITextAndImageHeaderViewInput

extension TextAndImageHeaderView: ITextAndImageHeaderViewInput {
    func set(title: String?) {
        titleLabel.text = title
    }

    func set(image: UIImage?) {
        imageView.image = image
    }
}

// MARK: - Constants

private extension CGFloat {
    static let imageViewOffset: CGFloat = 2
    static let imageViewSide: CGFloat = 24
}
