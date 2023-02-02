import UIKit

protocol CardFieldDelegate: AnyObject {
    func sizeDidChange(view: CardFieldView, size: CGSize)
    func cardFieldValidationResultDidChange(result: CardFieldValidationResult)
}

extension CardFieldDelegate {
    func sizeDidChange(view: CardFieldView, size: CGSize) {}
}

// MARK: - CardFieldView

//
// Usage Example
//
// let config = cardFieldFactory.assembleCardFieldConfig(view: cardField)
// let size = cardField.systemLayoutSizeFitting(.zero)
// cardFieldView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: size.height)
// cardFieldView.configure(with: config)

final class CardFieldView: UIView {

    var input: ICardFieldInput { presenter }
    weak var delegate: CardFieldDelegate?

    private let presenter: ICardFieldPresenter

    // MARK: - UI

    private let contentView = UIView()

    private let dynamicCardView = DynamicIconCardView()

    private let cardNumberTextField = FloatingTextField(insetsType: .commonAndHugeLeftInset)
    private let expireTextField = FloatingTextField()
    private let cvcTextField = FloatingTextField()

    // MARK: - Init

    init(presenter: ICardFieldPresenter) {
        self.presenter = presenter
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardFieldView {
    private func setupViews() {
        contentView.backgroundColor = .clear
        addSubview(contentView)

        contentView.addSubview(cardNumberTextField)
        contentView.addSubview(dynamicCardView)
        contentView.addSubview(expireTextField)
        contentView.addSubview(cvcTextField)
    }

    private func setupConstraints() {
        contentView.makeEqualToSuperview()

        cardNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        dynamicCardView.translatesAutoresizingMaskIntoConstraints = false
        expireTextField.translatesAutoresizingMaskIntoConstraints = false
        cvcTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardNumberTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            cardNumberTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardNumberTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cardNumberTextField.heightAnchor.constraint(equalToConstant: .textFieldHeight),

            dynamicCardView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .dynamicIconLeftInset),
            dynamicCardView.centerYAnchor.constraint(equalTo: cardNumberTextField.centerYAnchor),
            dynamicCardView.heightAnchor.constraint(equalToConstant: .dynamicIconHeight),
            dynamicCardView.widthAnchor.constraint(equalToConstant: .dynamicIconWidth),

            expireTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            expireTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: .bottomFieldsTopInset),
            expireTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            expireTextField.heightAnchor.constraint(equalToConstant: .textFieldHeight),
            expireTextField.widthAnchor.constraint(equalTo: cvcTextField.widthAnchor),

            cvcTextField.leftAnchor.constraint(equalTo: expireTextField.rightAnchor, constant: .cvcFieldLeftInset),
            cvcTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: .bottomFieldsTopInset),
            cvcTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            cvcTextField.heightAnchor.constraint(equalTo: expireTextField.heightAnchor),
        ])
    }
}

// MARK: - CardFieldView + ConfigurableItem

extension CardFieldView: IDynamicIconCardViewUpdater {

    func update(config: DynamicIconCardView.Model) {
        dynamicCardView.configure(model: config)
    }
}

extension CardFieldView: Activatable {
    var isActive: Bool {
        cardNumberTextField.isFirstResponder || expireTextField.isFirstResponder || cvcTextField.isFirstResponder
    }

    func activate() {
        guard !isActive else { return }
        cardNumberTextField.becomeFirstResponder()
    }

    func deactivate() {
        guard isActive else { return }
        cardNumberTextField.resignFirstResponder()
        expireTextField.resignFirstResponder()
        cvcTextField.resignFirstResponder()
    }
}

extension CardFieldView: Configurable {
    func update(with configuration: Config?) {
        guard let config = configuration else { return }

        config.dynamicCardIcon.updater = self
        dynamicCardView.configure(model: config.dynamicCardIcon)
        configure(textField: cardNumberTextField, with: config.cardNumberTextFieldConfig)
        configure(textField: expireTextField, with: config.expirationTextFieldConfig)
        configure(textField: cvcTextField, with: config.cvcTextFieldConfig)
    }
}

extension CardFieldView: ICardFieldView {
    func setHeaderErrorFor(textFieldType: CardFieldType) {
        getTextField(type: textFieldType).setHeader(color: ASDKColors.Foreground.negativeAccent)
    }

    func setHeaderNormalFor(textFieldType: CardFieldType) {
        getTextField(type: textFieldType).setHeader(color: ASDKColors.Text.secondary.color)
    }

    func activateExpirationField() {
        expireTextField.becomeFirstResponder()
    }

    func activateCvcField() {
        cvcTextField.becomeFirstResponder()
    }
}

extension CardFieldView {
    private func getTextField(type: CardFieldType) -> FloatingTextField {
        switch type {
        case .cardNumber: return cardNumberTextField
        case .expiration: return expireTextField
        case .cvc: return cvcTextField
        }
    }

    private func configure(textField: FloatingTextField, with config: FloatingTextField.Configuration) {
        textField.setHeader(text: config.headerLabel.content.text)
        textField.set(text: config.textField.content.text)
        textField.set(placeholder: config.textField.placeholder.text)
        textField.set(keyboardType: config.textField.keyboardType)
        textField.set(isSecureTextEntry: config.textField.isSecure)
        textField.delegate = config.textField.delegate
    }
}

// MARK: - Constants

private extension CGFloat {
    static let textFieldHeight: CGFloat = 56

    static let dynamicIconLeftInset: CGFloat = 12
    static let dynamicIconWidth: CGFloat = 40
    static let dynamicIconHeight: CGFloat = 26

    static let bottomFieldsTopInset: CGFloat = 12

    static let cvcFieldLeftInset: CGFloat = 11
}
