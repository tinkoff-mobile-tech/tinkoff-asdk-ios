//
//  AddNewCardViewController.swift
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

import TinkoffASDKCore
import UIKit
import WebKit

enum AddNewCardSection {
    case cardField
}

// MARK: - AddNewCardOutput

public protocol IAddNewCardOutput: AnyObject {
    func addingNewCardCompleted(result: AddCardResult)
}

// MARK: - AddNewCardView

protocol IAddNewCardView: AnyObject {
    func reloadCollection(sections: [AddNewCardSection])
    func showLoadingState()
    func hideLoadingState()
    func closeScreen()
    func disableAddButton()
    func enableAddButton()
    func activateCardField()
    func showOkNativeAlert(data: OkAlertData)
}

// MARK: - AddNewCardViewController

final class AddNewCardViewController: UIViewController {

    // MARK: Dependencies

    private let presenter: IAddNewCardPresenter

    // MARK: Properties

    private lazy var addCardView = AddNewCardView(delegate: self)
    private lazy var hiddenWebViewFor3DS = WKWebView()

    // MARK: Init

    init(presenter: IAddNewCardPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupHiddenWebView()
        setupAddNewCardView()
        presenter.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let isBeingDismissed = navigationController?.isBeingDismissed == true
        // Тречит дисмисс или свайп вью контроллера
        if isBeingDismissed || isMovingFromParent {
            presenter.viewWasClosed()
        }
    }
}

// MARK: - IAddNewCardView

extension AddNewCardViewController: IAddNewCardView {
    func reloadCollection(sections: [AddNewCardSection]) {
        addCardView.reloadCollection(sections: sections)
    }

    func showLoadingState() {
        addCardView.showLoadingState()
    }

    func hideLoadingState() {
        addCardView.hideLoadingState()
    }

    func activateCardField() {
        addCardView.activate()
    }

    func closeScreen() {
        let poppedViewController = navigationController?.popViewController(animated: true)
        if poppedViewController == nil {
            presentingViewController?.dismiss(animated: true)
        }
    }

    func showOkNativeAlert(data: OkAlertData) {
        let alert = UIAlertController.okAlert(data: data)
        present(alert, animated: true)
    }

    func disableAddButton() {
        addCardView.disableAddButton()
    }

    func enableAddButton() {
        addCardView.enableAddButton()
    }
}

// MARK: - ThreeDSWebFlowDelegate

extension AddNewCardViewController: ThreeDSWebFlowDelegate {
    func hiddenWebViewToCollect3DSData() -> WKWebView {
        hiddenWebViewFor3DS
    }

    func sourceViewControllerToPresent() -> UIViewController? {
        self
    }
}

// MARK: - Private Helpers

extension AddNewCardViewController {
    private func setupNavigationItem() {
        navigationItem.title = Loc.Acquiring.AddNewCard.screenTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Loc.Acquiring.AddNewCard.buttonClose,
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
    }

    private func setupHiddenWebView() {
        view.addSubview(hiddenWebViewFor3DS)
        hiddenWebViewFor3DS.pinEdgesToSuperview()
        hiddenWebViewFor3DS.isHidden = true
    }

    private func setupAddNewCardView() {
        view.addSubview(addCardView)
        addCardView.pinEdgesToSuperview()
    }

    @objc private func closeButtonTapped() {
        closeScreen()
    }
}

// MARK: - AddNewCardViewDelegate

extension AddNewCardViewController: AddNewCardViewDelegate {
    func cardFieldViewAddCardTapped() {
        presenter.cardFieldViewAddCardTapped()
    }

    func cardFieldViewPresenter() -> ICardFieldViewOutput {
        presenter.cardFieldViewPresenter()
    }
}
