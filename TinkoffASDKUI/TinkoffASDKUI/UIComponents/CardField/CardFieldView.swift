import UIKit

protocol CardFieldDelegate: AnyObject {
    func cardFieldValidationResultDidChange(result: CardFieldValidationResult)
}

final class CardFieldView: UIView {

    // MARK: Dependencies

    var input: ICardFieldInput { presenter }
    weak var delegate: CardFieldDelegate?

    private let presenter: ICardFieldPresenter
    private let maskingFactory: ICardFieldMaskingFactory

    private lazy var cardNumberDelegate: MaskedTextFieldDelegate = maskingFactory.buildForCardNumber(didFillMask: { [weak self] text, completed in
        self?.presenter.didFillCardNumber(text: text, filled: completed)
    }, didBeginEditing: { [weak self] in
        self?.presenter.didBeginEditing(fieldType: .cardNumber)
    }, didEndEditing: { [weak self] in
        self?.presenter.didEndEditing(fieldType: .cardNumber)
    }, listenerStorage: &textFieldListeners)

    private lazy var expirationDelegate: MaskedTextFieldDelegate = maskingFactory.buildForExpiration(didFillMask: { [weak self] text, completed in
        self?.presenter.didFillExpiration(text: text, filled: completed)
    }, didBeginEditing: { [weak self] in
        self?.presenter.didBeginEditing(fieldType: .expiration)
    }, didEndEditing: { [weak self] in
        self?.presenter.didEndEditing(fieldType: .expiration)
    }, listenerStorage: &textFieldListeners)

    private lazy var cvcDelegate: MaskedTextFieldDelegate = maskingFactory.buildForCvc(didFillMask: { [weak self] text, completed in
        self?.presenter.didFillCvc(text: text, filled: completed)
    }, didBeginEditing: { [weak self] in
        self?.presenter.didBeginEditing(fieldType: .cvc)
    }, didEndEditing: { [weak self] in
        self?.presenter.didEndEditing(fieldType: .cvc)
    }, listenerStorage: &textFieldListeners)

    // MARK: Properties

    private let contentView = UIView()

    private let dynamicCardView = DynamicIconCardView()

    private let cardNumberTextField = FloatingTextField(insetsType: .commonAndHugeLeftInset)
    private let expireTextField = FloatingTextField()
    private let cvcTextField = FloatingTextField()

    // MARK: State

    private var textFieldListeners: [NSObject] = []

    // MARK: Initialization

    init(presenter: ICardFieldPresenter, maskingFactory: ICardFieldMaskingFactory) {
        self.presenter = presenter
        self.maskingFactory = maskingFactory
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    func update(with configuration: CardFieldViewConfig?) {
        guard let config = configuration else { return }

        config.dynamicCardIcon.updater = self
        dynamicCardView.configure(model: config.dynamicCardIcon)

        cardNumberTextField.delegate = cardNumberDelegate
        expireTextField.delegate = expirationDelegate
        cvcTextField.delegate = cvcDelegate
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

// MARK: - Private

extension CardFieldView {
    private func setupViews() {
        contentView.backgroundColor = .clear
        addSubview(contentView)

        contentView.addSubview(cardNumberTextField)
        contentView.addSubview(dynamicCardView)
        contentView.addSubview(expireTextField)
        contentView.addSubview(cvcTextField)

        cardNumberTextField.setHeader(text: Loc.Acquiring.CardField.panTitle)
        cardNumberTextField.set(keyboardType: .numberPad)

        expireTextField.setHeader(text: Loc.Acquiring.CardField.termTitle)
        expireTextField.set(placeholder: Loc.Acquiring.CardField.termPlaceholder)
        expireTextField.set(keyboardType: .numberPad)

        cvcTextField.setHeader(text: Loc.Acquiring.CardField.cvvTitle)
        cvcTextField.set(placeholder: Loc.Acquiring.CardField.cvvPlaceholder)
        cvcTextField.set(keyboardType: .numberPad)
        cvcTextField.set(isSecureTextEntry: true)
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

    private func getTextField(type: CardFieldType) -> FloatingTextField {
        switch type {
        case .cardNumber: return cardNumberTextField
        case .expiration: return expireTextField
        case .cvc: return cvcTextField
        }
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
