//
//  FloatingTextField.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 31.01.2023.
//

import UIKit

final class FloatingTextField: UIView {

    // MARK: Dependencies

    weak var delegate: FloatingTextFieldDelegate?

    // MARK: Properties

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ASDKColors.Background.neutral1.color
        view.layer.cornerRadius = .containerViewRadius
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .clear
        textField.contentVerticalAlignment = .bottom
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        return textField
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = ASDKColors.Text.secondary.color
        label.numberOfLines = 1
        return label
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        return gesture
    }()

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

// MARK: - Actions

extension FloatingTextField {
    @objc private func tapGestureAction(_ sender: UITapGestureRecognizer) {
        textField.becomeFirstResponder()
    }

    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        delegate?.textField(textField, didChangeTextTo: textField.text ?? "")
    }
}

// MARK: - Public

extension FloatingTextField {
    func set(text: String) {
        textField.text = text
        if !text.isEmpty {
            liftHeaderLabel()
        }
    }

    func set(keyboardType: UIKeyboardType) {
        textField.keyboardType = keyboardType
    }

    func setHeader(text: String) {
        headerLabel.text = text
    }

    func setHeader(color: UIColor) {
        UIView.animate(withDuration: .defaultAnimationDuration) {
            self.headerLabel.textColor = color
        }
    }
}

// MARK: - UITextFieldDelegate

extension FloatingTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn(textField) ?? true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        liftHeaderLabel()
        delegate?.textFieldDidBeginEditing(textField)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.textField(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            downHeaderLabel()
        }
        delegate?.textFieldDidEndEditing(textField)
    }
}

// MARK: - Private

extension FloatingTextField {
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(textField)
        containerView.addSubview(headerLabel)
    }

    private func setupViewsConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: leftAnchor),
            containerView.rightAnchor.constraint(equalTo: rightAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            textField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: .textFieldLeftInset),
            textField.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -.textFieldRightInset),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: .textFieldTopInset),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -.textFieldBottomInset),

            headerLabel.leftAnchor.constraint(equalTo: textField.leftAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
        ])
    }

    private func liftHeaderLabel() {
        animateHeaderLabel(isLifting: true)
    }

    private func downHeaderLabel() {
        animateHeaderLabel(isLifting: false)
    }

    private func animateHeaderLabel(isLifting: Bool) {
        let headerLabelScale: CGFloat = isLifting ? .headerLabelLiftedScale : .headerLabelDownScale
        let headerLabelXTranslation: Double = isLifting ? -.headerLabelLiftingTranslationX : .zero
        let headerLabelYTranslation: Double = isLifting ? -.headerLabelLiftingTranslationY : .zero

        let translationTransform = CGAffineTransform(translationX: headerLabelXTranslation, y: headerLabelYTranslation)
        let scaleTransform = CGAffineTransform(scaleX: headerLabelScale, y: headerLabelScale)
        let allTransforms = scaleTransform.concatenating(translationTransform)

        UIView.animate(withDuration: .defaultAnimationDuration) {
            self.headerLabel.transform = allTransforms
        }
    }
}

// MARK: - Constants

private extension Double {
    static let headerLabelLiftingTranslationX: Double = 16
    static let headerLabelLiftingTranslationY: Double = 10
}

private extension CGFloat {
    static let headerLabelLiftedScale: CGFloat = 0.8
    static let headerLabelDownScale: CGFloat = 1

    static let containerViewRadius: CGFloat = 16

    static let textFieldLeftInset: CGFloat = 12
    static let textFieldRightInset: CGFloat = 7
    static let textFieldTopInset: CGFloat = 9
    static let textFieldBottomInset: CGFloat = 9
}
