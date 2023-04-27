//
//  SwitchView.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.01.2023.
//

import UIKit

typealias SwitchTableCell = TableCell<SwitchView>

final class SwitchView: UIView, ISwitchViewInput {
    // MARK: Internal Types

    enum Constants {
        static let minimalHeight: CGFloat = 40
        static let nameLabelRightInset: CGFloat = 8
    }

    // MARK: Dependencies

    var presenter: ISwitchViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Properties

    private lazy var nameLabel = UILabel()
    private lazy var switchButton = UISwitch()

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

    func setSwitchButtonState(isOn: Bool) {
        switchButton.isOn = isOn
    }
}

// MARK: - Actions

extension SwitchView {
    @objc private func switchButtonValueChanged(_ sender: UISwitch) {
        presenter?.switchButtonValueChanged(to: sender.isOn)
    }
}

// MARK: - Private

extension SwitchView {
    private func setupViews() {
        backgroundColor = .clear

        addSubview(nameLabel)
        addSubview(switchButton)

        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = ASDKColors.Text.primary.color

        switchButton.isOn = false
        switchButton.addTarget(self, action: #selector(switchButtonValueChanged(_:)), for: .valueChanged)
        switchButton.onTintColor = ASDKColors.accent
        switchButton.tintColor = ASDKColors.Background.neutral1.color
        switchButton.backgroundColor = ASDKColors.Background.neutral1.color
        switchButton.layer.cornerRadius = switchButton.frame.height / 2
    }

    private func setupViewsConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        switchButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimalHeight),

            nameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            nameLabel.rightAnchor.constraint(equalTo: switchButton.leftAnchor, constant: Constants.nameLabelRightInset),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            switchButton.rightAnchor.constraint(equalTo: rightAnchor),
            switchButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
