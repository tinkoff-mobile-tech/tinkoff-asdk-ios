//
//  AcquiringAlertViewController.swift
//  TinkoffASDKUI
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

public enum AcquiringAlertIconType {
    case error
    case success
    case icon(UIImage)
}

class AcquiringAlertViewController: UIViewController {
    static func create() -> AcquiringAlertViewController {
        let alert = AcquiringAlertViewController(nibName: "AcquiringAlertViewController", bundle: .uiResources)
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        _ = alert.view
        return alert
    }

    @IBOutlet private var viewAlertConteiner: UIView!
    @IBOutlet private var viewBorder: UIView!
    @IBOutlet private var visualEffectBackground: UIVisualEffectView!

    @IBOutlet private var imageViewAletIcon: UIImageView!
    @IBOutlet private var labelAlertTitle: UILabel!

    private var autoCloseTime: TimeInterval = 0
    private var closedFromTimer: Bool = false
    private var alertTouch: Bool = false {
        didSet {
            if alertTouch == false {
                if closedFromTimer == true {
                    dismiss(animated: true, completion: { [weak self] in self?.dimissCompletionClosure?() })
                }
            }
        }
    }
    
    private var dimissCompletionClosure: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        viewAlertConteiner.layer.cornerRadius = 20
        viewAlertConteiner.layer.shadowColor = labelAlertTitle.textColor.cgColor
        viewAlertConteiner.layer.shadowOpacity = 0.15
        viewAlertConteiner.layer.shadowOffset = .zero
        viewAlertConteiner.layer.shadowRadius = 20

        viewAlertConteiner.backgroundColor = .clear

        viewBorder.backgroundColor = .clear
        viewBorder.layer.cornerRadius = 20
        viewBorder.clipsToBounds = true

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:))))
        viewAlertConteiner.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alertViewTapped(_:))))

        modalPresentationStyle = .overCurrentContext
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startCloseTimer()
    }

    // MARK: Tap Gesture Recognizer

    @IBAction private func dimmingViewTapped(_: UITapGestureRecognizer) {
        dismiss(animated: true, completion: { [weak self] in self?.dimissCompletionClosure?() })
    }

    @IBAction private func alertViewTapped(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .began:
            if autoCloseTime > 0 {
                alertTouch = true
            } else {
                dismiss(animated: true, completion: { [weak self] in self?.dimissCompletionClosure?() })
            }

        case .ended, .cancelled, .failed:
            alertTouch = false

        default:
            break
        }
    }

    private func startCloseTimer() {
        if autoCloseTime > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                if let value = self?.alertTouch, value == false {
                    self?.dismiss(animated: true, completion: { [weak self] in
                        self?.dimissCompletionClosure?()
                    })
                } else {
                    self?.closedFromTimer = true
                }
            }
        }
    }

    public func present(on presentingViewController: UIViewController,
                        title: String,
                        icon: AcquiringAlertIconType = .success,
                        autoCloseTime: TimeInterval = 3,
                        dismissClosure: (() -> Void)? = nil) {
        self.autoCloseTime = autoCloseTime

        switch icon {
        case let .icon(img):
            imageViewAletIcon.image = img
        case .error:
            imageViewAletIcon.image = Asset.cancel.image
        default:
            imageViewAletIcon.image = Asset.done.image
        }

        labelAlertTitle.text = title
        
        self.dimissCompletionClosure = dismissClosure

        presentingViewController.present(self, animated: true)
    }
}
