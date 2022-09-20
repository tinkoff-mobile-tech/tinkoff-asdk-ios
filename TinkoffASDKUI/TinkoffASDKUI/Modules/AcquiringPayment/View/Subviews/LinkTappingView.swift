//
//
//  LinkTappingView.swift
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

final class LinkTappingView: UIView {
    // MARK: Action Handlers

    var onButtonTap: (() -> Void)?

    // MARK: Subviews

    private lazy var linkButton: UIButton = {
        let linkButton = UIButton(type: .system)
        linkButton.contentHorizontalAlignment = .leading
        linkButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        linkButton.setTitleColor(.asdk.accent, for: .normal)
        linkButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return linkButton
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    convenience init(title: String) {
        self.init(frame: .zero)
        set(title: title)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Updating

    func set(title: String) {
        linkButton.setTitle(title, for: .normal)
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(linkButton)
        linkButton.pinEdgesToSuperview()
    }

    // MARK: Actions

    @objc private func buttonTapped() {
        onButtonTap?()
    }
}
