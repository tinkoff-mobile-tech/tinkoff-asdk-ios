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
    static let nameSkeletonWidth: CGFloat = UIScreen.main.bounds.width * 0.4
    static let nameSkeletonHeight: CGFloat = 14
    static let nameSkeletonRadius: CGFloat = 4
}

private extension Double {
    static let waterfallDelay: Double = 0.2
}

private extension CGSize {
    static let logoImageSize = CGSize(width: .logoImageSide, height: .logoImageSide)
}

final class SBPBankCellNew: UITableViewCell {

    // Properties
    private let nameLabel = FadingLabel()
    private let logoImageView = UIImageView()

    private let nameSkeletonView = SkeletonView()
    private let logoImageSkeletonView = SkeletonView()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSkeletonViews()
        setupSkeletonViewsConstraints()
        setupViews()
        setupViewsConstraints()
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

        nameSkeletonView.stopSkeletonAnimations()
        logoImageSkeletonView.stopSkeletonAnimations()
    }
}

// MARK: - Public

extension SBPBankCellNew {
    func set(viewModel: SBPBankCellNewViewModel) {
        nameSkeletonView.isHidden = !viewModel.isSkeleton
        logoImageSkeletonView.isHidden = !viewModel.isSkeleton

        if viewModel.isSkeleton {
            nameSkeletonView.startAnimating(animationType: .waterfall(index: 0, delay: .waterfallDelay))
            logoImageSkeletonView.startAnimating(animationType: .waterfall(index: 1, delay: .waterfallDelay))
        } else {
            nameLabel.text = viewModel.nameLabelText

            if let image = viewModel.imageAsset?.image {
                logoImageView.image = image
            } else if let url = viewModel.logoURL {
                logoImageView.loadImage(at: url, type: .roundAndSize(.logoImageSize))
            }
        }
    }
}

// MARK: - Private

extension SBPBankCellNew {
    private func setupSkeletonViews() {
        contentView.addSubview(nameSkeletonView)
        contentView.addSubview(logoImageSkeletonView)

        let nameSkeletonModel = SkeletonView.Model(color: ASDKColors.Foreground.skeleton, cornerRadius: .nameSkeletonRadius)
        let logoImageSkeletonModel = SkeletonView.Model(color: ASDKColors.Foreground.skeleton, cornerRadius: .logoImageSide / 2)
        nameSkeletonView.configure(model: nameSkeletonModel)
        logoImageSkeletonView.configure(model: logoImageSkeletonModel)
    }

    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(logoImageView)

        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byClipping
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = ASDKColors.Text.primary.color
    }

    private func setupViewsConstraints() {
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

    private func setupSkeletonViewsConstraints() {
        nameSkeletonView.translatesAutoresizingMaskIntoConstraints = false
        logoImageSkeletonView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageSkeletonView.widthAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageSkeletonView.heightAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageSkeletonView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageSkeletonView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .logoImageLeftOffset),
            logoImageSkeletonView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .logoImageVerticalOffset),
            logoImageSkeletonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.logoImageVerticalOffset),

            nameSkeletonView.widthAnchor.constraint(equalToConstant: .nameSkeletonWidth),
            nameSkeletonView.heightAnchor.constraint(equalToConstant: .nameSkeletonHeight),
            nameSkeletonView.centerYAnchor.constraint(equalTo: logoImageSkeletonView.centerYAnchor),
            nameSkeletonView.leftAnchor.constraint(equalTo: logoImageSkeletonView.rightAnchor, constant: .nameLeftInset),
        ])
    }
}
