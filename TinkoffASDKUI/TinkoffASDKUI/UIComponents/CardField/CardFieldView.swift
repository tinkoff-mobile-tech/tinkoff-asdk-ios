import UIKit

protocol CardFieldDelegate: AnyObject {
    func sizeDidChange(view: CardFieldView, size: CGSize)
    func cardFieldValidationResultDidChange(result: CardFieldValidationResult)
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

    override var intrinsicContentSize: CGSize { self.frame.size }

    override var frame: CGRect {
        didSet {
            guard frame != oldValue else { return }
            handleFrameChange()
        }
    }

    private(set) var configuration: Config?

    var input: ICardFieldInput { presenter }
    weak var delegate: CardFieldDelegate?

    private let presenter: ICardFieldPresenter

    // MARK: - UI

    private let contentView = UIView()

    private let cardNumberView = UIView()
    private let expireView = UIView()
    private let cvcView = UIView()

    private let dynamicCardView = DynamicIconCardView()
    private let expireTextField = TextField()
    private let cardNumberTextField = TextField()
    private let cvcTextField = TextField()

    // MARK: - Other

    private var observation: NSKeyValueObservation?

    private var cardNumberWidthAnchor: NSLayoutConstraint?
    private var expireWidthAnchor: NSLayoutConstraint?
    private var cvcWidthAnchor: NSLayoutConstraint?

    // MARK: - Init

    init(presenter: ICardFieldPresenter) {
        self.presenter = presenter
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // remove
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        endEditing(true)
    }
}

extension CardFieldView {

    private func setupViews() {
        observation = observe(\.center) { [weak self] _, _ in
            self?.handleFrameChange()
        }

        addViews()
        setupConstraints()
    }

    private func addViews() {
        contentView.backgroundColor = .clear
        addSubview(contentView)
        contentView.makeEqualToSuperview()

        contentView.addSubview(cardNumberView)
        contentView.addSubview(expireView)
        contentView.addSubview(cvcView)

        cardNumberView.addSubview(dynamicCardView)
        cardNumberView.addSubview(cardNumberTextField)
        expireView.addSubview(expireTextField)
        cvcView.addSubview(cvcTextField)
    }

    private func setupConstraints() {

        // Card Number
        let cardNumberWidthAnchor = cardNumberView.width(constant: .zero)
        self.cardNumberWidthAnchor = cardNumberWidthAnchor

        cardNumberView.makeConstraints { make in
            [
                cardNumberWidthAnchor,
                make.height(constant: Constants.Card.height),
                make.topAnchor.constraint(equalTo: make.forcedSuperview.topAnchor),
                make.leftAnchor.constraint(equalTo: make.forcedSuperview.leftAnchor),
            ]
        }

        dynamicCardView.makeConstraints { make in
            [
                make.topAnchor.constraint(equalTo: make.forcedSuperview.topAnchor, constant: Constants.Card.DynamicIcon.topInset),
                make.leftAnchor.constraint(equalTo: make.forcedSuperview.leftAnchor, constant: Constants.Card.DynamicIcon.leftInset),
            ] + make.size(Constants.Card.DynamicIcon.size)
        }

        cardNumberTextField.makeConstraints { view in
            [
                view.leftAnchor.constraint(equalTo: dynamicCardView.rightAnchor, constant: Constants.Card.TextField.leftInset),
                view.topAnchor.constraint(equalTo: view.forcedSuperview.topAnchor, constant: Constants.Card.TextField.topInset),
                view.rightAnchor.constraint(equalTo: view.forcedSuperview.rightAnchor, constant: -Constants.Card.TextField.rightInset),
            ]
        }

        // Expire

        expireView.makeConstraints { make in
            let width = make.width(constant: 0)
            expireWidthAnchor = width

            return [
                make.leftAnchor.constraint(equalTo: make.forcedSuperview.leftAnchor),
                make.topAnchor.constraint(equalTo: cardNumberView.bottomAnchor, constant: Constants.Expiration.topInset),
                make.height(constant: Constants.Expiration.height),
                width,
                make.bottomAnchor.constraint(lessThanOrEqualTo: make.forcedSuperview.bottomAnchor),
            ]
        }

        expireTextField.makeEqualToSuperview(insets: Constants.Expiration.TextField.insets)

        // CVC

        cvcView.makeConstraints { make in
            let width = make.width(constant: 0)
            cvcWidthAnchor = width

            return [
                make.rightAnchor.constraint(equalTo: make.forcedSuperview.rightAnchor),
                make.topAnchor.constraint(equalTo: cardNumberView.bottomAnchor, constant: Constants.Expiration.topInset),
                make.height(constant: Constants.Cvc.height),
                width,
            ]
        }

        cvcTextField.makeEqualToSuperview(insets: Constants.Cvc.TextField.insets)
    }

    private func handleFrameChange() {
        contentView.layoutIfNeeded()
        let width = (contentView.frame.size.width / 2) - (Constants.Cvc.leftInset / 2)
        cardNumberWidthAnchor?.constant = contentView.frame.size.width
        expireWidthAnchor?.constant = width
        cvcWidthAnchor?.constant = width
        delegate?.sizeDidChange(view: self, size: bounds.size)
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
        cardNumberTextField.isActive || expireTextField.isActive || cvcTextField.isActive
    }

    func activate() {
        guard !isActive else { return }
        cardNumberTextField.activate()
    }

    func deactivate() {
        guard isActive else { return }
        cardNumberTextField.deactivate()
        expireTextField.deactivate()
        cvcTextField.deactivate()
    }
}

extension CardFieldView: ConfigurableItem {

    // MARK: - Public

    func configure(with config: Config?) {
        prepareForReuse()
        guard let config = config else { return }
        apply(style: config.style)

        config.dynamicCardIcon.updater = self
        dynamicCardView.configure(model: config.dynamicCardIcon)
        expireTextField.configure(with: config.expirationTextFieldConfig)
        cardNumberTextField.configure(with: config.cardNumberTextFieldConfig)
        cvcTextField.configure(with: config.cvcTextFieldConfig)
        config.onDidConfigure?()
    }

    // MARK: - Private

    private func apply(style: Style) {
        cardNumberView.layer.cornerRadius = style.card.cornerRadius
        cardNumberView.backgroundColor = style.card.backgroundColor

        expireView.layer.cornerRadius = style.card.cornerRadius
        expireView.backgroundColor = style.card.backgroundColor

        cvcView.layer.cornerRadius = style.cvc.cornerRadius
        cvcView.backgroundColor = style.cvc.backgroundColor
    }
}

extension CardFieldView: Reusable, Configurable {

    func update(with configuration: Config?) {
        configure(with: configuration)
    }

    func prepareForReuse() {
        cardNumberView.layer.cornerRadius = .zero
        cardNumberView.backgroundColor = .clear
        expireView.layer.cornerRadius = .zero
        expireView.backgroundColor = .clear
        cvcView.layer.cornerRadius = .zero
        cvcView.backgroundColor = .clear
    }
}

extension CardFieldView: ICardFieldView {

    func activateExpirationField() {
        expireTextField.activate()
    }

    func activateCvcField() {
        cvcTextField.activate()
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
