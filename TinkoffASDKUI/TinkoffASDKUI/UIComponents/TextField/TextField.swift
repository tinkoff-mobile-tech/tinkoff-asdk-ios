//
//  SmartTextField.swift
//  popup
//
//  Created by Ivan Glushko on 23.11.2022.
//

import UIKit

final class TextField: UIView, Editable {

    var isActive: Bool { textField.isFirstResponder }
    var isEditing: Bool { textField.isEditing }

    var text: String { textField.text ?? "" }

    override var intrinsicContentSize: CGSize { CGSize(width: frame.width, height: Constants.height) }
    private(set) var configuration: Configuration = .empty

    private var notificationTokens: [NSObjectProtocol] = []
    private var isTitleShrinked = false
    private var titleAnimation = Animation()

    private var hasContentOrActive: Bool { isActive || text.isEmpty == false }
    private var userHasInteracted = false

    // MARK: - UI

    private let headerLabel = UILabel()
    private let textField = UITextField()
    private let accessoryViewContainer = UIView()

    private lazy var accessoryWidthConstraint = accessoryViewContainer.width(constant: .zero)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupObservers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeObervers()
    }

    // MARK: - Activatable

    func activate() {
        textField.becomeFirstResponder()
    }

    func deactivate() {
        textField.resignFirstResponder()
    }

    // MARK: - Private

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.becomeFirstResponder()
    }

    private func setupViews() {
        addSubview(headerLabel)
        addSubview(textField)
        addSubview(accessoryViewContainer)

        accessoryViewContainer.makeConstraints { make in
            let result = make.makeTopAndBottomEqualToSuperView(inset: .zero)
                + [
                    accessoryWidthConstraint,
                    make.rightAnchor.constraint(equalTo: make.forcedSuperview.rightAnchor),
                ]
            return result
        }

        textField.makeConstraints { make in
            [
                make.leftAnchor.constraint(equalTo: make.forcedSuperview.leftAnchor),
                make.rightAnchor.constraint(equalTo: accessoryViewContainer.leftAnchor),
                make.height(constant: intrinsicContentSize.height * Constants.heightOfTextFieldRelation),
                make.bottomAnchor.constraint(equalTo: make.forcedSuperview.bottomAnchor),
            ]
        }
    }

    private func setupObservers() {
        let didBeginToken = NotificationCenter.default.addObserver(
            forName: UITextField.textDidBeginEditingNotification,
            object: textField,
            queue: .main,
            using: { [weak self] _ in
                self?.didBeginEditing()
            }
        )

        let didChangeToken = NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: textField,
            queue: .main,
            using: { [weak self] _ in
                self?.didChangeText()
            }
        )

        let didEndToken = NotificationCenter.default.addObserver(
            forName: UITextField.textDidEndEditingNotification,
            object: textField,
            queue: .main,
            using: { [weak self] _ in
                self?.didEndEditing()
            }
        )

        notificationTokens = [didBeginToken, didChangeToken, didEndToken]
    }

    private func removeObervers() {
        notificationTokens.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Events

    private func didBeginEditing() {
        userHasInteracted = true
        showTitle(
            hasContentOrActive: hasContentOrActive,
            animated: true
        )
        configuration.textField.eventHandler?(.didBeginEditing, self)
        if case .clearButton = configuration.textField.rightAccessoryView?.kind {
            let content = (configuration.textField.rightAccessoryView?.content as? DeleteButtonContent)
            content?.didChangeActiveState(isActive: true, hasText: !text.isEmpty)
        }

        setPlaceholder(configuration.textField.placeholder)
    }

    private func didChangeText() {
        configuration.textField.eventHandler?(.textDidChange, self)
        if case .clearButton = configuration.textField.rightAccessoryView?.kind {
            let content = (configuration.textField.rightAccessoryView?.content as? DeleteButtonContent)
            content?.didChangeText(hasText: !text.isEmpty)
        }
    }

    private func didEndEditing() {
        showTitle(
            hasContentOrActive: hasContentOrActive,
            animated: true
        )
        configuration.textField.eventHandler?(.didEndEditing, self)
        if case .clearButton = configuration.textField.rightAccessoryView?.kind {
            let content = (configuration.textField.rightAccessoryView?.content as? DeleteButtonContent)
            content?.didChangeActiveState(isActive: false, hasText: !text.isEmpty)
        }
        setPlaceholder(nil)
    }

    // MARK: - Animations

    private func showTitle(hasContentOrActive: Bool, animated: Bool = true) {
        guard !titleAnimation.isAnimating else { return }

        hasContentOrActive
            ? shrinkTitle(animated: animated)
            : unshrinkTitle(animated: animated)

        isTitleShrinked = hasContentOrActive
    }

    private func shrinkTitle(animated: Bool) {
        let animation = UIView.Animation(
            body: {
                let scaleFactor = Constants.scaleFactor
                self.headerLabel.layer.position = .zero
                self.headerLabel.transform = .identity
                    .scaledBy(x: scaleFactor, y: scaleFactor)
            },
            completion: { _ in }
        )

        headerLabel.layer.anchorPoint = .zero
        headerLabel.layer.position = CGPoint(x: 0, y: headerLabel.layer.position.y)

        titleAnimation = animation

        guard animated else {
            animation.body()
            animation.completion(true)
            return
        }

        UIView.animate(
            withDuration: Constants.animationDuration,
            curve: CAMediaTimingFunction(name: .easeInEaseOut),
            delay: .zero,
            usingSpringWithDamping: Constants.springDamping,
            initialSpringVelocity: .zero,
            options: [],
            animations: titleAnimation.body,
            completion: { [weak titleAnimation] didEnd in
                titleAnimation?.isAnimating = false
                titleAnimation?.completion(didEnd)
            }
        )
    }

    private func unshrinkTitle(animated: Bool) {
        let animation = UIView.Animation(
            body: {
                let originY = (self.intrinsicContentSize.height / 2) - ((self.textField.font?.lineHeight ?? 0) / 2)
                self.headerLabel.transform = .identity
                self.headerLabel.layer.position = CGPoint(x: 0, y: originY)
            },
            completion: { _ in }
        )

        titleAnimation = animation
        titleAnimation.isAnimating = true

        headerLabel.layer.anchorPoint = .zero

        guard animated else {
            animation.body()
            titleAnimation.isAnimating = false
            animation.completion(true)
            return
        }

        titleAnimation.isAnimating = true
        UIView.animate(
            withDuration: Constants.animationDuration,
            curve: CAMediaTimingFunction(name: .easeInEaseOut),
            delay: .zero,
            usingSpringWithDamping: Constants.springDamping,
            initialSpringVelocity: .zero,
            options: [],
            animations: titleAnimation.body,
            completion: { [weak titleAnimation] didEnd in
                titleAnimation?.isAnimating = false
                titleAnimation?.completion(didEnd)
            }
        )
    }
}

// MARK: - ConfigurableItem

extension TextField: ConfigurableItem {

    func configure(with config: Configuration) {
        config.updater = self
        prepareForReuse()
        configuration = config
        apply(textFieldConfig: config.textField)

        textField.setNeedsLayout()
        textField.layoutIfNeeded()

        let headerLabelHeight = textField.font?.lineHeight ?? 0
        headerLabel.frame = CGRect(
            x: 0,
            y: (intrinsicContentSize.height / 2) - (headerLabelHeight / 2),
            width: textField.frame.width,
            height: headerLabelHeight
        )

        headerLabel.configure(config.headerLabel)
        showTitle(hasContentOrActive: hasContentOrActive, animated: false)
    }

    private func apply(textFieldConfig config: TextFieldConfiguration) {
        textField.delegate = config.delegate
        textField.isSecureTextEntry = config.isSecure
        textField.tintColor = config.tintColor
        textField.keyboardType = config.keyboardType

        switch config.content {
        case let .plain(text, style):
            textField.textColor = style.textColor
            textField.font = style.font
            if let text = text {
                putText(text)
            }

        case let .attributed(string):
            textField.attributedText = string
        }

        setupAccessoryView(config.rightAccessoryView)
    }

    func prepareForReuse() {
        configuration = .empty
        accessoryViewContainer.subviews.forEach { $0.removeFromSuperview() }

        textField.placeholder = nil
        textField.attributedPlaceholder = nil
        textField.delegate = nil
        textField.isSecureTextEntry = false
        textField.tintColor = nil
        textField.textColor = nil
        textField.font = nil
        textField.attributedText = nil
    }

    private func setupAccessoryView(_ accessoryView: TextField.AccessoryView?) {
        guard let accessoryView = accessoryView else {
            return
        }

        accessoryView.content.delegate = self
        if let deleteContent = accessoryView.content as? DeleteButtonContent, deleteContent.buttonDelegate == nil {
            deleteContent.buttonDelegate = self
        }

        accessoryView.content.addAccessoryViewAndConstraints(
            containerAccessoryView: accessoryViewContainer
        )
    }

    func setPlaceholder(_ content: UILabel.Content?) {
        guard let content = content else {
            textField.placeholder = nil
            textField.attributedPlaceholder = nil
            return
        }

        switch content {
        case let .plain(text, _):
            textField.placeholder = text
        case let .attributed(string):
            textField.attributedPlaceholder = string
        }
    }

    private func putText(_ text: String) {
        if let maskedDelegate = textField.delegate as? MaskedTextFieldDelegate {
            maskedDelegate.put(text: text, into: textField)
            textField.sendActions(for: .valueChanged)
            didChangeText()
        } else {
            let shouldChange = textField.delegate?.textField?(
                textField,
                shouldChangeCharactersIn: NSRange(location: 0, length: text.count),
                replacementString: text
            )

            if shouldChange ?? true {
                textField.text = text
                textField.sendActions(for: .valueChanged)
                didChangeText()
            }
        }
    }
}

protocol ITextFieldUpdater: AnyObject {

    func updateHeader(config: UILabel.Configuration)
}

extension TextField: ITextFieldUpdater {

    func updateHeader(config: UILabel.Configuration) {
        headerLabel.configure(config)
    }
}

extension TextField: DeleteButtonContentDelegate {

    func didTapClearAccessoryButton() {
        putText("")
    }

    func hideAccessoryContentView() {
        accessoryWidthConstraint.constant = 0
    }

    func showAccessoryContentView(width: CGFloat) {
        accessoryWidthConstraint.constant = width
    }
}
