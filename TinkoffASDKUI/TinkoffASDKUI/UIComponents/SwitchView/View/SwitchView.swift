//
//  SwitchView.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.01.2023.
//

final class SwitchView: UIView, ISwitchViewInput {

    // MARK: Dependencies

    var presenter: ISwitchViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Properties

    private lazy var nameLabel = UILabel()
    private lazy var buttonSwitch = UISwitch()

    // MARK: Initialization

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
        setupViewsConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ISwitchViewInput

extension SwitchView {
    func setNameLabel(text: String?) {
        nameLabel.text = text
    }

    func setSwitchState(isOn: Bool) {
        buttonSwitch.isOn = isOn
    }
}

// MARK: - Actions

extension SwitchView {
    @objc private func settingSwitchValueChanged(_ sender: UISwitch) {
        presenter?.switchDidChangeState(to: sender.isOn)
    }
}

// MARK: - Private

extension SwitchView {
    private func setupViews() {
        backgroundColor = .clear

        addSubview(nameLabel)
        addSubview(buttonSwitch)

        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = ASDKColors.Text.primary.color

        buttonSwitch.isOn = false
        buttonSwitch.addTarget(self, action: #selector(settingSwitchValueChanged(_:)), for: .valueChanged)
        buttonSwitch.onTintColor = ASDKColors.accent
        buttonSwitch.tintColor = ASDKColors.Background.neutral1.color
        buttonSwitch.backgroundColor = ASDKColors.Background.neutral1.color
        buttonSwitch.layer.cornerRadius = buttonSwitch.frame.height / 2
    }

    private func setupViewsConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonSwitch.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            nameLabel.rightAnchor.constraint(equalTo: buttonSwitch.leftAnchor, constant: .nameLabelRightInset),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            buttonSwitch.rightAnchor.constraint(equalTo: rightAnchor),
            buttonSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// MARK: - Constants

private extension CGFloat {
    static let nameLabelRightInset: CGFloat = 8
}
