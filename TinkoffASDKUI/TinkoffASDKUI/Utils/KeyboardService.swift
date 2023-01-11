//
//  KeyboardService.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 20.12.2022.
//

import UIKit

final class KeyboardService {

    // Local
    var onHeightDidChangeBlock: (_ keyboardHeight: CGFloat, _ animationDuration: Double) -> Void = { _, _ in }

    // Init

    init() {
        setObservers()
    }

    deinit {
        removeObservers()
    }
}

private extension KeyboardService {

    func setObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func willShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? NSDictionary else { return }
        guard let keyboardFrame = userInfo.value(
            forKey: UIResponder.keyboardFrameEndUserInfoKey
        ) as? NSValue else { return }

        guard let animationDuration = userInfo.value(
            forKey: UIResponder.keyboardAnimationDurationUserInfoKey
        ) as? Double else { return }

        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        onHeightDidChangeBlock(keyboardHeight, animationDuration)
    }

    @objc func willHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? NSDictionary else { return }
        guard let animationDuration = userInfo.value(
            forKey: UIResponder.keyboardAnimationDurationUserInfoKey
        ) as? Double else { return }

        onHeightDidChangeBlock(.zero, animationDuration)
    }
}
