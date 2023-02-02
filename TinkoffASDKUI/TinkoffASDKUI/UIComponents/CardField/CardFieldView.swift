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
            cardNumberTextField.heightAnchor.constraint(equalToConstant: Constants.Card.height),

            dynamicCardView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.Card.DynamicIcon.leftInset),
            dynamicCardView.centerYAnchor.constraint(equalTo: cardNumberTextField.centerYAnchor),
            dynamicCardView.heightAnchor.constraint(equalToConstant: Constants.Card.DynamicIcon.size.height),
            dynamicCardView.widthAnchor.constraint(equalToConstant: Constants.Card.DynamicIcon.size.width),

            expireTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            expireTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: Constants.Expiration.topInset),
            expireTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            expireTextField.heightAnchor.constraint(equalToConstant: Constants.Expiration.height),
            expireTextField.widthAnchor.constraint(equalTo: cvcTextField.widthAnchor),

            cvcTextField.leftAnchor.constraint(equalTo: expireTextField.rightAnchor, constant: Constants.Cvc.leftInset),
            cvcTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: Constants.Expiration.topInset),
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

extension CardFieldView {
    private func configure(textField: FloatingTextField, with config: TextField.Configuration) {
        textField.setHeader(text: config.headerLabel.content.text)
        textField.set(text: config.textField.content.text)
        textField.set(placeholder: config.textField.placeholder.text)
        textField.set(keyboardType: config.textField.keyboardType)
        textField.set(isSecureTextEntry: config.textField.isSecure)
        textField.delegate = config.textField.delegate
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
    func activateExpirationField() {
        expireTextField.becomeFirstResponder()
    }

    func activateCvcField() {
        cvcTextField.becomeFirstResponder()
    }
}

// MARK: - Default Styles

extension CardFieldView.Style {

    static var regular: Self {
        let color = ASDKColors.Background.neutral1.color

        return CardFieldView.Style(
            card: Card(
                backgroundColor: color, cornerRadius: 16
            ),
            expiration: Expiration(backgroundColor: color, cornerRadius: 16),
            cvc: Cvc(backgroundColor: color, cornerRadius: 16)
        )
    }
}
