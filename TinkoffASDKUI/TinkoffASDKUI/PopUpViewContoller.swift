//
//  PopUpViewContoller.swift
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

class PopUpViewContoller: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet private weak var headContainerView: UIView!
	@IBOutlet private weak var headPinchView: UIView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var viewWaiting: UIView!
	
	// modal presentation
	private var currentPopUpViewMaxHeight: CGFloat = {
		let result = UIScreen.main.bounds.size.height - 34
		return result
	}()
	
	private var disappearComletionHandler: (() -> Void)?
	
	private var lastCurrentHeight: CGFloat?
	
	var modalMinHeight: CGFloat = 400 {
		didSet {
			//if currentHeight < modalMinHeight {
			currentHeight = modalMinHeight
			//}
		}
	}
	
	private var currentHeight: CGFloat = 430 {
		didSet {
			lastCurrentHeight = currentHeight
		}
	}
	private var beginDelta: CGFloat = 0
	private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
	private weak var didAppearTextFieldNeedBecomeFirstResponder: UIView?
	
	// MARK: Lifecycle
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOnTableView(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideOnTableView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		panGesture.delegate = self
		view.addGestureRecognizer(panGesture)
		
		view.backgroundColor = .clear
		headPinchView.backgroundColor = UIColor.init(hex: "#C7C9CC")
		headPinchView.layer.cornerRadius = 2
		
		headContainerView.layer.cornerRadius = 12
		headContainerView.clipsToBounds = true
		headContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		currentPopUpViewMaxHeight = maxPopUpViewHeight(UIScreen.main.traitCollection)
		preferredContentSize = CGSize(width: view.bounds.size.width, height: currentHeight)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		didAppearTextFieldNeedBecomeFirstResponder?.becomeFirstResponder()
		didAppearTextFieldNeedBecomeFirstResponder = nil
		
		if currentHeight > currentPopUpViewMaxHeight {
			_ = pushToNavigationStackAndActivate(firstResponder: nil)
		}
		
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		disappearComletionHandler?()
	}
	
	func closeViewController(_ complete: (() -> Void)? = nil) {
		if let nav = navigationController {
			disappearComletionHandler = complete
			nav.popViewController(animated: true)
		} else {
			dismiss(animated: true) {
				complete?()
			}
		}
	}
	
	///
	/// обновление размеров для `firstResponder.inputAccessoryView`
	/// если такой есть и если он реализует протокол `ViewSizeDependenceUITraitCollectionSize`
	func updateView() {
		
		if let firstResponder = view.firstResponder {
			let trailCollection = firstResponder.traitCollection
			if let view = firstResponder.inputAccessoryView as? ViewSizeDependenceUITraitCollectionSize {
				view.updateViewSize(for: trailCollection)
			}
		}
		
	}
	
	private func maxPopUpViewHeight(_ traitCollection: UITraitCollection) -> CGFloat{
		let minHeight = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
		let maxHeight = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
		
		return traitCollection.verticalSizeClass == .compact ? minHeight - 24 : maxHeight - 34
	}
	
	// MARK: UIContentContainer
	
	override public func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
		super.willTransition(to: newCollection, with: coordinator)
		
		updatePreferredContentSizeWithTraitCollection(newCollection)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { (_) in
			//
		}) { [weak self] (context) in
			self?.updateView()
		}
		
	}
	
	func updatePreferredContentSizeWithTraitCollection(_ traitCollection: UITraitCollection) {
		currentPopUpViewMaxHeight = maxPopUpViewHeight(traitCollection)
		
		if currentHeight > currentPopUpViewMaxHeight {
			let last = currentHeight
			currentHeight = currentPopUpViewMaxHeight
			lastCurrentHeight = last
		} else if let last = lastCurrentHeight, last > currentHeight {
			currentHeight = last
		}
		
		preferredContentSize = CGSize(width: view.bounds.size.width, height: currentHeight)
	}
	
	// MARK: Modal Interaction Presentation
	
	@objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
		if let win = view.window {
			let translationY = pan.translation(in: win).y
			var newHeight = beginDelta - translationY
			
			switch pan.state {
				case .began:
					beginDelta = view.bounds.size.height
				
				case .changed:
					if newHeight >= modalMinHeight && newHeight < currentPopUpViewMaxHeight {
						if newHeight < modalMinHeight {
							newHeight = modalMinHeight
						} else if newHeight > currentPopUpViewMaxHeight {
							newHeight = currentPopUpViewMaxHeight
						}
						
						preferredContentSize = CGSize(width: view.bounds.size.width, height: CGFloat(newHeight))
					} else if newHeight > currentPopUpViewMaxHeight {
						newHeight = currentPopUpViewMaxHeight
						_ = pushToNavigationStackAndActivate(firstResponder: view.firstResponder)
					}
				
				case .ended:
					if currentHeight < currentPopUpViewMaxHeight {
						currentHeight = preferredContentSize.height
					}
				
				default:
					break
			}
		}
	}
	
	func pushToNavigationStackAndActivate(firstResponder textField: UIView?, completion: (() -> Void)? = nil) -> Bool {
		if panGesture.delegate == nil {
			return true
		}
		
		panGesture.isEnabled = false
		panGesture.reset()
		panGesture.delegate = nil
		didAppearTextFieldNeedBecomeFirstResponder = textField
		
		if let nav = presentingViewController as? UINavigationController {
			dismiss(animated: false) {
				nav.pushViewController(self, animated: false)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					completion?()
				}

			}
			
			return false
			
		} else if let parentViewController = presentingViewController {
			dismiss(animated: false) {
				parentViewController.present(self, animated: false) {
					completion?()
				}
			}
			
			return false
		}
		
		return true
	}
	
	// MARK: FirstResponder, Resize Content Insets
	
	@objc func keyboardWillShowOnTableView(notification: NSNotification) {
		keyboardWillShow(notification: notification)
	}
	
	@objc func keyboardWillHideOnTableView(notification: NSNotification) {
		keyboardWillHide(notification: notification)
	}
	
	func keyboardWillShow(notification: NSNotification) {
		if let userInfo = notification.userInfo as NSDictionary?, let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue {
			let keyboardRectangle = keyboardFrame.cgRectValue
			let keyboardHeight = keyboardRectangle.height
			let inputAccessoryViewHeight: CGFloat = (view.firstResponder?.inputAccessoryView?.frame.size.height) ?? 0
			let keyboardContentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: ((keyboardHeight) + inputAccessoryViewHeight), right: 0)
			
			if let cell: UITableViewCell = UIView.searchTableViewCell(by: view.firstResponder) {
				let firstResponderHeight = keyboardContentInset.bottom + cell.bounds.height + cell.frame.origin.y + tableView.frame.origin.y
				
				var delaySetContentInset: TimeInterval = 0
				if firstResponderHeight > preferredContentSize.height {
					preferredContentSize = CGSize(width: preferredContentSize.width, height: firstResponderHeight)
					delaySetContentInset = 0.3
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
						if let height = self?.currentPopUpViewMaxHeight, firstResponderHeight > height {
							_ = self?.pushToNavigationStackAndActivate(firstResponder: self?.view.firstResponder )
						}
					}
					
				}//firstRespondetTop > preferredContentSize.height
				
				UIView.animate(withDuration: 0.3, delay: delaySetContentInset, options: .curveEaseOut, animations: { [weak self] in
					self?.tableView.contentInset = keyboardContentInset
				})
			}
		}
	}
	
	func keyboardDidShow() {
		if let cell: UITableViewCell = UIView.searchTableViewCell(by: view.firstResponder), let indexPath = tableView.indexPath(for: cell) {
			tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		UIView.animate(withDuration: 0.3) { [weak self] in
			self?.tableView.contentInset = UIEdgeInsets.zero
		}
	}

}

extension PopUpViewContoller: UIGestureRecognizerDelegate {
	
	// MARK: UIGestureRecognizerDelegate
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		if (otherGestureRecognizer.view as? UICollectionView) != nil {
			return false
		}

		return true
	}
	
}
