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

final class PullableContainerViewController: UIViewController {

    private var customView: PullableContainerView {
        return (view as? PullableContainerView) ?? PullableContainerView()
    }

    private let content: PullableContainerContent & UIViewController

    private var dragController: PullableContainerDragController?
    private var dragHandlers = [PullableContainerDragHandler]()

    private var cachedViewHeight: CGFloat = 0

    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { dimmingTransitioningDelegate }
        set {}
    }

    override var modalPresentationStyle: UIModalPresentationStyle {
        get { .custom }
        set {}
    }

    // swiftlint:disable:next weak_delegate
    private lazy var dimmingTransitioningDelegate = DimmingTransitioningDelegate(dimmingPresentationControllerDelegate: self)

    init(content: PullableContainerContent & UIViewController) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle

    override func loadView() {
        view = PullableContainerView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if cachedViewHeight != view.bounds.height {
            cachedViewHeight = view.bounds.height
            customView.layoutIfNeeded()
            dragController?.insets.top = customView.headerView.bounds.height
            updateContainerHeight(contentHeight: content.pullableContainerContentHeight)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        dragController?.insets.bottom = view.safeAreaInsets.bottom
    }
}

private extension PullableContainerViewController {
    func setup() {
        setupContent()
        setupDragController()
        setupDragHandlers()
    }

    func setupContent() {
        addChild(content)
        customView.addContent(content)
        content.didMove(toParent: self)

        content.pullableContainerContentHeightDidChange = { [weak self] content in
            self?.dragHandlers.forEach { $0.cancel() }
            self?.updateContainerHeight(contentHeight: content.pullableContainerContentHeight)
        }
    }

    func setupDragController() {
        dragController = PullableContainerDragController(
            dragViewHeightConstraint: customView.dragViewHeightConstraint
        )
        dragController?.delegate = self
    }

    func setupDragHandlers() {
        let panGesture = UIPanGestureRecognizer()
        customView.dragView.addGestureRecognizer(panGesture)

        let panGestureHandler = PullableContainerPanGestureDragHandler(
            dragController: dragController,
            panGestureRecognizer: panGesture
        )

        let scrollHandler = PullableContainerScrollDragHandler(
            dragController: dragController,
            scrollView: customView.scrollView
        )

        dragHandlers = [panGestureHandler, scrollHandler]
    }

    func updateContainerHeight(contentHeight: CGFloat) {
        let maximumContentHeight = calculateMaximumContentHeight()
        let targetContentHeight = min(maximumContentHeight, contentHeight)
        dragController?.setDefaultPositionWithContentHeight(targetContentHeight)
        customView.containerViewHeightConstraint.constant = targetContentHeight
        customView.scrollView.isScrollEnabled = targetContentHeight >= maximumContentHeight

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 2,
            options: .curveEaseInOut
        ) {
            self.customView.layoutIfNeeded()
        }
    }

    func calculateMaximumContentHeight() -> CGFloat {
        view.bounds.height
            - view.safeAreaInsets.top
            - view.safeAreaInsets.bottom
            - customView.headerView.bounds.height
    }
}

// MARK: - PullableContainerDragControllerDelegate

extension PullableContainerViewController: PullableContainerDragControllerDelegate {
    func pullableContainerDragControllerDidEndDragging(_ controller: PullableContainerDragController) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 2,
            options: .curveEaseInOut
        ) {
            self.customView.layoutIfNeeded()
        }
    }

    func pullableContainerDragControllerDidCloseContainer(_ controller: PullableContainerDragController) {
        dismiss(animated: true)
        content.pullableContainerWillBeClosed()
        transitionCoordinator?.animate(alongsideTransition: nil, completion: { [weak self] _ in
            self?.content.pullableContainerWasClosed()
        })
    }

    func pullableContainerDragControllerDidRequestMaxContentHeight(_ controller: PullableContainerDragController) -> CGFloat {
        calculateMaximumContentHeight()
    }

    func pullableContainerDragControllerShouldDismissOnDownDragging(_ controller: PullableContainerDragController) -> Bool {
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
