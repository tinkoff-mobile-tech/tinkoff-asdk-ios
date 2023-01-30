//
//  EmailView.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

import UIKit

final class EmailView: UIView, IEmailViewInput {

    // MARK: Dependencies

    var presenter: IEmailViewOutput? {
        didSet {
            if oldValue?.view === self { oldValue?.view = nil }
            presenter?.view = self
        }
    }

    // MARK: Properties

    private lazy var contentView = UIView()
    private lazy var textField = TextField()

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

// MARK: - IEmailViewInput

extension EmailView {
    func setTextFieldHeaderError() {
        setTextFieldHeader(color: ASDKColors.Foreground.negativeAccent)
    }

    func setTextFieldHeaderNormal() {
        setTextFieldHeader(color: ASDKColors.Text.secondary.color)
    }

    func setTextField(text: String) {
        setupTextField(with: text)
    }

    func hideKeyboard() {
        endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension EmailView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        presenter?.textFieldDidPressReturn()
        return true
    }
}

// MARK: - Private

extension EmailView {
    private func setupViews() {
        backgroundColor = .clear

        addSubview(contentView)
        contentView.addSubview(textField)

        contentView.backgroundColor = ASDKColors.Background.neutral1.color
        contentView.layer.cornerRadius = 16

        setupTextField(with: "")
    }

    private func setupViewsConstraints() {
        contentView.pinEdgesToSuperview()

        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .textFieldLeftInset),
            textField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -.textFieldRightInset),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    private func setTextFieldHeader(color: UIColor) {
        let headerLabelStyle = UILabel.Style.bodyL().set(textColor: color)
        let headerLabelContent = UILabel.Content.plain(text: .textFieldName, style: headerLabelStyle)
        let headerConfig = UILabel.Configuration(content: headerLabelContent)

        textField.updateHeader(config: headerConfig)
    }

    private func setupTextField(with text: String) {
        let textFieldConfig = TextField.TextFieldConfiguration(
            delegate: self,
            eventHandler: { [weak self] event, textField in
                switch event {
                case .didBeginEditing:
                    self?.presenter?.textFieldDidBeginEditing()
                case .textDidChange:
                    self?.presenter?.textFieldDidChangeText(to: textField.text)
                case .didEndEditing:
                    self?.presenter?.textFieldDidEndEditing()
                }
            },
            content: .plain(text: text, style: .bodyL()),
            placeholder: .plain(text: "", style: .bodyL()),
            tintColor: nil,
            rightAccessoryView: TextField.AccessoryView(kind: .clearButton),
            isSecure: false,
            keyboardType: .default
        )

        let headerLabelStyle = UILabel.Style.bodyL().set(textColor: ASDKColors.Text.secondary.color)
        let headerLabelContent = UILabel.Content.plain(text: .textFieldName, style: headerLabelStyle)
        let headerConfig = UILabel.Configuration(content: headerLabelContent)

        let textFieldAndHeaderConfig = TextField.Configuration(textField: textFieldConfig, headerLabel: headerConfig)
        textField.configure(with: textFieldAndHeaderConfig)
    }
}

// MARK: - Constants

private extension String {
    static let textFieldName: String = Loc.Acquiring.EmailField.title
}

private extension CGFloat {
    static let textFieldLeftInset: CGFloat = 12
    static let textFieldRightInset: CGFloat = 20
}
