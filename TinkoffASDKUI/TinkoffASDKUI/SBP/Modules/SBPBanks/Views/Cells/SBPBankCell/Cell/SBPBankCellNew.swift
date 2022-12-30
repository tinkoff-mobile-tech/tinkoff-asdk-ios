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

final class SBPBankCellNew: UITableViewCell, ISBPBankCellNew {

    // Dependencies
    var presenter: ISBPBankCellNewPresenter? {
        didSet {
            if oldValue?.cell === self { oldValue?.cell = nil }
            presenter?.cell = self
        }
    }

    // Properties
    private let nameLabel = FadingLabel()
    private let logoImageView = UIImageView()

    private let nameSkeletonView = SkeletonView()
    private let logoImageSkeletonView = SkeletonView()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
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

        selectionStyle = .default

        nameLabel.text = ""
        logoImageView.image = nil

        nameSkeletonView.isHidden = true
        logoImageSkeletonView.isHidden = true
        nameSkeletonView.stopSkeletonAnimations()
        logoImageSkeletonView.stopSkeletonAnimations()
    }
}

// MARK: - ISBPBankCellNew

extension SBPBankCellNew {
    func showSkeletonViews() {
        selectionStyle = .none

        nameSkeletonView.isHidden = false
        logoImageSkeletonView.isHidden = false

        nameSkeletonView.startAnimating(animationType: .waterfall(index: 0, delay: .waterfallDelay))
        logoImageSkeletonView.startAnimating(animationType: .waterfall(index: 1, delay: .waterfallDelay))
    }

    func setNameLabel(text: String) {
        nameLabel.text = text
    }

    func setLogo(image: UIImage, animated: Bool) {
        let duration: TimeInterval = animated ? .defaultAnimationDuration : 0

        UIView.transition(
            with: logoImageView,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: {
                self.logoImageView.image = image
            }
        )
    }
}

// MARK: - Private

extension SBPBankCellNew {
    private func setupCell() {
        selectionStyle = .default
    }

    private func setupSkeletonViews() {
        contentView.addSubview(nameSkeletonView)
        contentView.addSubview(logoImageSkeletonView)

        nameSkeletonView.isHidden = true
        logoImageSkeletonView.isHidden = true

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
            logoImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .logoImageLeftOffset),
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .logoImageVerticalOffset),
            logoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.logoImageVerticalOffset),

            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: .nameLeftInset),
            nameLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -.nameRightInset),
        ])
    }

    private func setupSkeletonViewsConstraints() {
        nameSkeletonView.translatesAutoresizingMaskIntoConstraints = false
        logoImageSkeletonView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageSkeletonView.widthAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageSkeletonView.heightAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageSkeletonView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .logoImageLeftOffset),
            logoImageSkeletonView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .logoImageVerticalOffset),
            logoImageSkeletonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.logoImageVerticalOffset),

            nameSkeletonView.widthAnchor.constraint(equalToConstant: .nameSkeletonWidth),
            nameSkeletonView.heightAnchor.constraint(equalToConstant: .nameSkeletonHeight),
            nameSkeletonView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameSkeletonView.leftAnchor.constraint(equalTo: logoImageSkeletonView.rightAnchor, constant: .nameLeftInset),
        ])
    }
}
