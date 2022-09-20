//
//
//  SBPUrlPaymentView.swift
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

final class SBPUrlPaymentView: UIView {

    private let contentContainer = UIView()
    private let loadingContainer = UIView()
    private var contentView: UIView?
    private var loadingView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func placeLoadingView(_ loadingView: UIView) {
        self.loadingView?.removeFromSuperview()
        self.loadingView = loadingView

        loadingContainer.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: loadingContainer.topAnchor),
            loadingView.leftAnchor.constraint(equalTo: loadingContainer.leftAnchor),
            loadingView.bottomAnchor.constraint(equalTo: loadingContainer.bottomAnchor),
            loadingView.rightAnchor.constraint(equalTo: loadingContainer.rightAnchor),
        ])
    }

    func placeContentView(_ contentView: UIView) {
        self.contentView?.removeFromSuperview()
        self.contentView = contentView

        contentContainer.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            contentView.leftAnchor.constraint(equalTo: contentContainer.leftAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: contentContainer.rightAnchor),
        ])
    }

    func showLoading() {
        loadingContainer.isHidden = false
    }

    func hideLoading() {
        loadingContainer.isHidden = true
    }
}

private extension SBPUrlPaymentView {
    func setup() {
        addSubview(contentContainer)
        addSubview(loadingContainer)

        contentContainer.backgroundColor = .clear
        loadingContainer.backgroundColor = .clear

        setupConstraints()
    }

    func setupConstraints() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        loadingContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: topAnchor),
            contentContainer.leftAnchor.constraint(equalTo: leftAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentContainer.rightAnchor.constraint(equalTo: rightAnchor),

            loadingContainer.topAnchor.constraint(equalTo: topAnchor),
            loadingContainer.leftAnchor.constraint(equalTo: leftAnchor),
            loadingContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            loadingContainer.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
}
