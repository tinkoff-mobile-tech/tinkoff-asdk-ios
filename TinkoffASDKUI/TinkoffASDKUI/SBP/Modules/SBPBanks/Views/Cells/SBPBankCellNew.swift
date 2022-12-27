//
//  SBPBankCellNew.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.12.2022.
//

private extension CGFloat {
    static let logoImageSide: CGFloat = 40
    static let logoImageVerticalOffset: CGFloat = 8
    static let logoImageLeftOffset: CGFloat = 16
    static let nameLeftInset: CGFloat = 16
    static let nameRightInset: CGFloat = 16
}

private extension CGSize {
    static let logoImageSize = CGSize(width: .logoImageSide, height: .logoImageSide)
}

final class SBPBankCellNew: UITableViewCell {

    // Properties
    private let nameLabel = UILabel()
    private let logoImageView = UIImageView()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = ""
        logoImageView.image = nil
        logoImageView.cancelImageLoad()
    }
}

// MARK: - Public

extension SBPBankCellNew {
    func set(viewModel: SBPBankCellNewViewModel) {
        nameLabel.text = viewModel.nameLabelText
        logoImageView.image = Asset.Sbp.sbpLogo.image

        if let url = viewModel.logoURL {
            logoImageView.loadImage(at: url, type: .roundAndSize(.logoImageSize))
        }
    }
}

// MARK: - Private

extension SBPBankCellNew {
    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(logoImageView)

        nameLabel.numberOfLines = 1
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = ASDKColors.Text.primary.color
    }

    private func setupConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageView.heightAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .logoImageLeftOffset),
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .logoImageVerticalOffset),
            logoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.logoImageVerticalOffset),

            nameLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            nameLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: .nameLeftInset),
            nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -.nameRightInset),
        ])
    }
}
