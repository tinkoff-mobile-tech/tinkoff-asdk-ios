//
//
//  LoadingViewController.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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

final class LoadingViewController: UIViewController, PullableContainerContent {
    var pullableContainerContentHeight: CGFloat {
        return 100
    }

    var pullableContainerContentHeightDidChange: ((PullableContainerContent) -> Void)?

    private let activityIndicator = UIActivityIndicatorView()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        startActivity()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pullableContainerContentHeightDidChange?(self)
    }

    func startActivity() {
        activityIndicator.startAnimating()
    }

    func stopActivity() {
        activityIndicator.stopAnimating()
    }

    func configure(with text: String) {
        statusLabel.text = text
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateActivityIndicatorStyle()
    }
}

private extension LoadingViewController {
    func setup() {
        view.backgroundColor = ASDKColors.Background.elevation1.color
        view.addSubview(activityIndicator)
        view.addSubview(statusLabel)

        statusLabel.textColor = ASDKColors.n3
        statusLabel.font = .boldSystemFont(ofSize: .statusLabelFontSize)

        activityIndicator.style = .gray
        setupContraints()
    }

    func setupContraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
        ])

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: .statusLabelOffset),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    func updateActivityIndicatorStyle() {
        if #available(iOS 13.0, *) {
            switch UITraitCollection.current.userInterfaceStyle {
            case .dark:
                activityIndicator.style = .white
            case .light:
                activityIndicator.style = .gray
            default:
                activityIndicator.style = .white
            }
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let statusLabelOffset = 12 as CGFloat
    static let statusLabelFontSize = 13 as CGFloat
}
