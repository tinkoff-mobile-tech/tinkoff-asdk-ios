//
//  ConfirmViewController.swift
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

class ConfirmViewController: UIViewController {
    var onCancel: (() -> Void)?

    private var needOnCancelNotification: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        var cancelButton: UIBarButtonItem

        if #available(iOS 13.0, *) {
            cancelButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeViewColtroller))
        } else {
            cancelButton = UIBarButtonItem(title: L10n.TinkoffAcquiring.Button.close, style: .done, target: self, action: #selector(closeViewColtroller))
        }

        navigationItem.setRightBarButton(cancelButton, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        if needOnCancelNotification {
            onCancel?()
        }

        super.viewDidDisappear(animated)
    }

    @objc func closeViewColtroller() {
        needOnCancelNotification = false
        if let presetingVC = presentingViewController {
            presetingVC.dismiss(animated: true) {
                self.onCancel?()
            }
        } else {
            if let nav = navigationController {
                nav.popViewController(animated: true)
                onCancel?()
            } else {
                dismiss(animated: true) {
                    self.onCancel?()
                }
            }
        }
    }
}
