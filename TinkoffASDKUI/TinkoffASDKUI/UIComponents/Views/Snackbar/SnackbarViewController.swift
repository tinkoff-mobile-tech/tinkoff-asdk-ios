//
//  SnackbarViewController.swift
//  popup
//
//  Created by Ivan Glushko on 18.11.2022.
//

import UIKit

/// In order to use snacks make sure to conform to ISnackPresentable
final class SnackbarViewController: UIViewController {

    private(set) var state = State.hidden {
        didSet {
            stateDidChange(state: state)
        }
    }

    private var didSetStateToShownActions: [String: () -> Void] = [:]
    private var animations: [() -> Void] = []
    private var hasPendingHidingAnimation = false

    private var viewDidAppear = false
    private var showedAtTime: DispatchTime?

    private var snackbarView: SnackbarView?

    override func loadView() {
        view = PassthroughView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
        if !animations.isEmpty {
            animations.forEach { $0() }
        }

        animations = []
    }
}

extension SnackbarViewController {

    /// Показать снек (с анимацией)
    func showSnackView(config: SnackbarView.Configuration, completion: (() -> Void)? = nil) {
        state = .showing
        let snackbarView = SnackbarView()
        self.snackbarView = snackbarView
        view.addSubview(snackbarView)
        let shownFrame = getShownSnackFrame()
        let hiddenFrame = getHiddenSnackFrame()

        snackbarView.frame = hiddenFrame
        snackbarView.configure(with: config)

        let animationItem = Animation(
            body: {
                // 1
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 1,
                    animations: {
                        var frame = shownFrame
                        frame.origin.y -= (frame.height / 8)
                        snackbarView.frame = frame
                    }
                )

                // 2
                UIView.addKeyframe(
                    withRelativeStartTime: 0.8,
                    relativeDuration: 1,
                    animations: {
                        snackbarView.frame = shownFrame
                    }
                )
            },
            completion: {
                self.state = .shown
                completion?()
            }
        )

        let animation = {
            UIView.animateKeyframes(
                withDuration: .animation,
                delay: .zero,
                options: .calculationModeCubic,
                animations: {
                    animationItem.body()
                },
                completion: { _ in
                    animationItem.completion()
                }
            )
        }

        if !viewDidAppear {
            animations.append(animation)
        } else {
            animation()
        }
    }

    /// Убрать снек (с анимацией или без)
    func hideSnackView(animated: Bool = true, completion: (() -> Void)? = nil) {
        if state == .showing {
            didSetStateToShownActions[#function] = { [weak self] in
                self?.hideSnackView(animated: animated, completion: completion)
            }
        }

        guard state == .shown else { return }

        let hasPassedShowingTimeTreshold = hasPassedShowingTimeTreshold(
            timeTreshold: 0.5,
            hideAnimationBlock: {
                self.hideSnackView(animated: animated, completion: completion)
            }
        )

        guard hasPassedShowingTimeTreshold else { return }
        guard let snackbarView = snackbarView else { return }
        state = .hiding

        let animation = Animation(
            body: {
                snackbarView.frame = self.getHiddenSnackFrame()
            },
            completion: { [weak self] in
                self?.state = .hidden
                self?.view.removeFromSuperview()
                completion?()
            }
        )

        if animated {
            UIView.animate(
                withDuration: .animation,
                delay: .zero,
                animations: {
                    animation.body()
                }, completion: { _ in
                    animation.completion()
                }
            )
        } else {
            animation.body()
            animation.completion()
        }
    }
}

// MARK: - Private methods

extension SnackbarViewController {

    private func setupViews() {
        view.backgroundColor = .clear
    }

    private func getShownSnackFrame() -> CGRect {
        CGRect(
            x: Constants.sideInset,
            y: view.frame.maxY
                - SnackbarView.defaultSize.height
                - (Constants.bottomInset + UIApplication.shared.keyWindow!.safeAreaInsets.bottom),
            width: SnackbarView.defaultSize.width,
            height: SnackbarView.defaultSize.height
        )
    }

    private func getHiddenSnackFrame() -> CGRect {
        let shownFrame = getShownSnackFrame()
        return CGRect(
            x: shownFrame.origin.x,
            y: view.frame.maxY,
            width: shownFrame.width,
            height: shownFrame.height
        )
    }

    private func stateDidChange(state: State) {
        switch state {
        case .hiding:
            break
        case .hidden:
            showedAtTime = nil
        case .showing:
            break
        case .shown:
            showedAtTime = .now()
            didSetStateToShownActions.values.forEach { closure in closure() }
        }
    }

    private func hasPassedShowingTimeTreshold(
        timeTreshold: Double,
        hideAnimationBlock: @escaping () -> Void
    ) -> Bool {

        var passedShowingTimeTreshold = true
        guard !hasPendingHidingAnimation else { return false }

        if let showedAtTime = showedAtTime {
            let diff = DispatchTime.now().uptimeNanoseconds - showedAtTime.uptimeNanoseconds
            let diffInSeconds = Double(diff) / 1_000_000_000

            passedShowingTimeTreshold = diffInSeconds > timeTreshold
            if !passedShowingTimeTreshold {
                hasPendingHidingAnimation = true

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + (timeTreshold - diffInSeconds),
                    execute: { [weak self] in
                        guard let self = self else { return }
                        self.hasPendingHidingAnimation = false
                        hideAnimationBlock()
                    }
                )
            }
        }
        return passedShowingTimeTreshold
    }
}

extension SnackbarViewController {

    enum State {
        case hiding
        case hidden
        case showing
        case shown
    }

    struct Animation {
        let body: () -> Void
        let completion: () -> Void
    }

    struct Constants {

        static var sideInset: CGFloat { 16 }
        static var bottomInset: CGFloat { 24 }
    }
}

private extension TimeInterval {

    static let animation: Self = 0.300
}
