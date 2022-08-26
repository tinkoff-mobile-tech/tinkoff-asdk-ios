//
//
//  OverlayLoadingView.swift
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

final class OverlayLoadingView: UIView {
    // MARK: Style

    struct Style {
        let overlayColor: UIColor

        init(overlayColor: UIColor = .asdk.dynamic.background.elevation1) {
            self.overlayColor = overlayColor
        }
    }

    // MARK: State

    enum State {
        case shown
        case hidden
    }

    var state: State = .hidden {
        didSet { transition(from: oldValue, to: state) }
    }

    // MARK: Dependencies

    private let style: Style

    // MARK: Subviews

    private lazy var loader: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style

        if #available(iOS 13, *) {
            style = .medium
        } else {
            style = .gray
        }
        let loader = UIActivityIndicatorView(style: style)
        loader.hidesWhenStopped = true
        return loader
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = style.overlayColor
        view.isHidden = true
        return view
    }()

    // MARK: Init

    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Parent Methods

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTestedView = super.hitTest(point, with: event)
        return hitTestedView === self ? nil : hitTestedView
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(overlayView)
        overlayView.pinEdgesToSuperview()

        addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.centerYAnchor.constraint(equalTo: centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    // MARK: State Applying

    private func transition(from oldState: State, to newState: State) {
        let preparation = { [self] in
            switch (oldState, newState) {
            case (.hidden, .hidden), (.shown, .shown):
                break
            case (.hidden, .shown):
                overlayView.alpha = .zero
                overlayView.isHidden = false
                loader.alpha = .zero
                loader.startAnimating()
            case (.shown, .hidden):
                overlayView.alpha = .overlayAlpha
                overlayView.isHidden = false
                loader.alpha = .loaderAlpha
            }
        }

        let animation = { [self] in
            switch (oldState, newState) {
            case (.hidden, .hidden), (.shown, .shown):
                break
            case (.hidden, .shown):
                overlayView.alpha = .overlayAlpha
                loader.alpha = .loaderAlpha
            case (.shown, .hidden):
                overlayView.alpha = .zero
                loader.alpha = .zero
            }
        }

        let completion = { [self] in
            switch (oldState, newState) {
            case (.hidden, .hidden), (.shown, .shown), (.hidden, .shown):
                break
            case (.shown, .hidden):
                overlayView.isHidden = true
                loader.stopAnimating()
            }
        }

        preparation()
        UIView.animate(
            withDuration: .animationDuration,
            delay: newState == .shown ? .animationDelay : .zero,
            options: [.curveEaseInOut, .beginFromCurrentState],
            animations: animation,
            completion: { _ in completion() }
        )
    }
}

// MARK: - Constants

private extension TimeInterval {
    static let animationDuration: TimeInterval = 0.2
    static let animationDelay: TimeInterval = 0.3
}

private extension CGFloat {
    static let overlayAlpha: CGFloat = 0.5
    static let loaderAlpha: CGFloat = 1
}
