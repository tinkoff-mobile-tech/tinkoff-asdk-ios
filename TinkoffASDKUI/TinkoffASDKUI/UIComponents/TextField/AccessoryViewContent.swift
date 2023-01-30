//
//  AccessoryViewContent.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 28.11.2022.
//

import UIKit

protocol IAccessoryViewContent: AnyObject {
    var delegate: AccessoryContentViewDelegate? { get set }

    var customViewWidth: CGFloat { get }
    func addAccessoryViewAndConstraints(containerAccessoryView: UIView)
}

protocol DeleteButtonContentDelegate: AccessoryContentViewDelegate {
    func didTapClearAccessoryButton()
}

final class DeleteButtonContent: IAccessoryViewContent {
    weak var delegate: AccessoryContentViewDelegate?
    weak var buttonDelegate: DeleteButtonContentDelegate?

    static let leftInset: CGFloat = 6
    static let buttonSize = CGSize(width: 16, height: 16)

    let customViewWidth: CGFloat = DeleteButtonContent.buttonSize.width + DeleteButtonContent.leftInset

    var state = State.hidden {
        didSet {
            handleStateChange(state: state)
        }
    }

    func addAccessoryViewAndConstraints(containerAccessoryView: UIView) {

        let button = Button()
        let buttonConfig = Button.Configuration(
            data: Button.Data(
                text: nil,
                onTapAction: { [weak self] in
                    self?.buttonDelegate?.didTapClearAccessoryButton()
                }
            ),
            style: Button.Style(
                background: .image(
                    normal: Asset.Icons.clear.image,
                    highlighted: nil,
                    disabled: nil
                ),
                cornerRadius: 0,
                loaderStyle: .standart,
                contentEdgeInsets: .zero,
                basicTextStyle: nil
            )
        )
        button.configure(buttonConfig)

        containerAccessoryView.addSubview(button)
        button.makeConstraints { make in
            make.size(CGSize(width: Self.buttonSize.width, height: Self.buttonSize.height)) +
                make.makeCenterEqualToSuperview() +
                [
                    make.leftAnchor.constraint(equalTo: make.forcedSuperview.leftAnchor, constant: Self.leftInset),
                    make.rightAnchor.constraint(equalTo: make.forcedSuperview.rightAnchor),
                ]
        }
    }

    /// Call from outside
    func didChangeText(hasText: Bool) {
        let newState: State = hasText ? .shown : .hidden
        state = newState
    }

    func didChangeActiveState(isActive: Bool, hasText: Bool) {
        if !isActive {
            state = .hidden
        }

        if hasText, isActive {
            state = .shown
        }
    }

    private func handleStateChange(state: State) {
        switch state {
        case .hidden:
            buttonDelegate?.hideAccessoryContentView()
        case .shown:
            buttonDelegate?.showAccessoryContentView(width: customViewWidth)
        }
    }

    enum State {
        case shown
        case hidden
    }
}

protocol AccessoryContentViewDelegate: AnyObject {

    func hideAccessoryContentView()
    func showAccessoryContentView(width: CGFloat)
}
