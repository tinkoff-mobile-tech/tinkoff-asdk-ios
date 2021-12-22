//
//
//  DimmingPresentationController.swift
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

protocol DimmingPresentationControllerDelegate: AnyObject {
    func didDismissByDimmingViewTap(dimmingPresentationController: DimmingPresentationController)
}

final class DimmingPresentationController: UIPresentationController {
     
    weak var dimmingPresentationControllerDelegate: DimmingPresentationControllerDelegate?
    
    private let dimmingView = DimmingView()
    
    override init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        setupDimmingView()
        setupTapDismissGesture()
        containerView?.layoutIfNeeded()
        dimmingView.prepareForPresentationTransition()
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [dimmingView] _ in
            dimmingView.performPresentationTransition()
        },
        completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        dimmingView.prepareForDimissalTransition()
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [dimmingView] _ in
            dimmingView.performDismissalTransition()
        }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = containerView?.bounds ?? .zero
    }
}

private extension DimmingPresentationController {
    func setupTapDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissTapGestureAction(_:)))
        dimmingView.addGestureRecognizer(tapGesture)
    }
    
    func setupDimmingView() {
        containerView?.addSubview(dimmingView)
    }
    
    @objc func dismissTapGestureAction(_ recognizer: UITapGestureRecognizer) {
        dimmingPresentationControllerDelegate?.didDismissByDimmingViewTap(dimmingPresentationController: self)
        presentedViewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

