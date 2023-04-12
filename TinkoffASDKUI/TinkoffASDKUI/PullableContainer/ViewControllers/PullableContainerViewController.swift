//
//
//  PullableContainerViewController.swift
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

func printFunction(function: String = #function) {
    print("DEBUG: \(function)")
}

final class PullableContainerViewController: UIViewController {
    // MARK: UIViewController's Properties

    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { dimmingTransitioningDelegate }
        set {}
    }

    override var modalPresentationStyle: UIModalPresentationStyle {
        get { .custom }
        set {}
    }

    // MARK: Subviews

    private lazy var containerView = PullableContainerView()

    // MARK: Dependencies

    private let content: PullableContainerContent & UIViewController
    private lazy var dimmingTransitioningDelegate = DimmingTransitioningDelegate(dimmingPresentationControllerDelegate: self)

    private lazy var heightConstraintController = PullableContainerHeightConstraintController(
        dragViewHeightConstraint: containerView.dragViewHeightConstraint,
        delegate: self
    )

    // MARK: State

    private var dragHandlers = [PullableContainerDragHandler]()
    private var cachedViewHeight: CGFloat = 0

    // MARK: Init

    init(content: PullableContainerContent & UIViewController) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Life Cycle

    override func loadView() {
        printFunction()
        view = containerView
    }

    override func viewDidLoad() {
        printFunction()
        super.viewDidLoad()
        setupContent()
        setupDragHandlers()
    }

    override func viewDidLayoutSubviews() {
        printFunction()
        super.viewDidLayoutSubviews()
        if cachedViewHeight != view.bounds.height {
            cachedViewHeight = view.bounds.height
            containerView.layoutIfNeeded()
            heightConstraintController.insets.top = containerView.headerView.bounds.height
            updateHeight(animated: false)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        printFunction()
        super.viewSafeAreaInsetsDidChange()
        heightConstraintController.insets.bottom = view.safeAreaInsets.bottom
    }

    // MARK: Initial Configuration

    private func setupContent() {
        addChild(content)
        content.didMove(toParent: self)
        containerView.add(contentView: content.view)
    }

    private func setupDragHandlers() {
        printFunction()
        let panGesture = UIPanGestureRecognizer()
        containerView.dragView.addGestureRecognizer(panGesture)

        let panGestureHandler: PullableContainerDragHandler = PullableContainerPanGestureDragHandler(
            heightConstraintController: heightConstraintController,
            panGestureRecognizer: panGesture
        )

        let scrollHandler: PullableContainerDragHandler? = content.pullableContainerDidRequestScrollView(self).map {
            PullableContainerScrollDragHandler(
                heightConstraintController: heightConstraintController,
                scrollView: $0
            )
        }

        dragHandlers = [panGestureHandler, scrollHandler].compactMap { $0 }
    }

    // MARK: Helpers

    private func calculateMaximumContentHeight() -> CGFloat {
        view.bounds.height
            - view.safeAreaInsets.top
            - view.safeAreaInsets.bottom
            - containerView.headerView.bounds.height
    }
}

// MARK: - PullableContainerСontentDelegate

extension PullableContainerViewController: PullableContainerСontentDelegate {
    func updateHeight(animated: Bool, completion: VoidBlock?) {
        printFunction()
        dragHandlers.forEach { $0.cancel() }
        heightConstraintController.updateHeight()

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 2,
            options: .curveEaseInOut
        ) {
            self.containerView.layoutIfNeeded()
        }
    }
}

// MARK: - PullableContainerDragControllerDelegate

extension PullableContainerViewController: PullableContainerHeightConstraintControllerDelegate {
    func heightConstraintControllerDidRequestNumberOfAnchors(_ controller: PullableContainerHeightConstraintController) -> Int {
        content.pullableContainerDidRequestNumberOfAnchors(self)
    }

    func heightConstraintController(_ controller: PullableContainerHeightConstraintController, didChange currentAnchorIndex: Int) {
        content.pullableContainer(self, didChange: currentAnchorIndex)
    }

    func heightConstraintControllerDidRequestCurrentAnchorIndex(_ controller: PullableContainerHeightConstraintController) -> Int {
        content.pullableContainerDidRequestCurrentAnchorIndex(self)
    }

    func heightConstraintController(
        _ controller: PullableContainerHeightConstraintController,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat {
        content.pullableContainer(self, didRequestHeightForAnchorAt: index, availableSpace: availableSpace)
    }

    func heightConstraintController(_ controller: PullableContainerHeightConstraintController, shouldUseAnchorAt index: Int) -> Bool {
        content.pullabeContainer(self, canReachAnchorAt: index)
    }

    func heightConstraintControllerDidEndDragging(_ controller: PullableContainerHeightConstraintController) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 2,
            options: .curveEaseInOut
        ) {
            self.containerView.layoutIfNeeded()
        }
    }

    func heightConstraintControllerDidCloseContainer(_ controller: PullableContainerHeightConstraintController) {
        dismiss(animated: true)

        content.pullableContainerWillBeClosed()
        transitionCoordinator?.animate(alongsideTransition: nil, completion: { [weak self] _ in
            self?.content.pullableContainerWasClosed()
        })
    }

    func heightConstraintControllerDidRequestAvailableSpace(_ controller: PullableContainerHeightConstraintController) -> CGFloat {
        calculateMaximumContentHeight()
    }

    func heightConstraintControllerShouldDismissOnDownDragging(_ controller: PullableContainerHeightConstraintController) -> Bool {
        content.pullableContainerShouldDismissOnDownDragging()
    }
}

// MARK: - DimmingPresentationControllerDelegate

extension PullableContainerViewController: DimmingPresentationControllerDelegate {
    func dimmingPresentationControllerDidDismissByDimmingViewTap(_ dimmingPresentationController: DimmingPresentationController) {
        content.pullableContainerWillBeClosed()
        transitionCoordinator?.animate(alongsideTransition: nil, completion: { [weak self] _ in
            self?.content.pullableContainerWasClosed()
        })
    }

    func dimmingPresentationControllerShouldDismissOnDimmingViewTap(_ dimmingPresentationController: DimmingPresentationController) -> Bool {
        content.pullableContainerShouldDismissOnDimmingViewTap()
    }
}
