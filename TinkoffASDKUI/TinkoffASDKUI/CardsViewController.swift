//
//  CardsViewController.swift
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

class CardsViewController: UIViewController {
    enum State {
        case loading
        case error(Error)
        case data
    }
    
    private enum TableSections: Int {
        case cards
        case addNew
    }

    private var tableViewSection: [TableSections] = []

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var viewWaiting: UIView!

    var addCardNeedSetCheckTypeHandler: (() -> PaymentCardCheckType)?
    var cardsController: CardsController!
    weak var scanerDataSource: AcquiringScanerProtocol?
    weak var alertViewHelper: AcquiringAlertViewProtocol?

    private var cardRequisitesBrandInfo: CardRequisitesBrandInfoProtocol = CardRequisitesBrandInfo()
    private var cards = [PaymentCard]()
    private var state: State = .data {
        didSet { tableView.reloadData() }
    }

    private lazy var buttonClose: UIBarButtonItem = {
        if #available(iOS 13.0, *) {
            return UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeView(_:)))
        } else {
            return UIBarButtonItem(title: AcqLoc.instance.localize("TinkoffAcquiring.button.close"), style: .done, target: self, action: #selector(closeView(_:)))
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if title == nil {
            title = AcqLoc.instance.localize("TinkoffAcquiring.view.title.savedCards")
        }

        tableView.register(UINib(nibName: "PaymentCardTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "PaymentCardTableViewCell")
        tableView.register(UINib(nibName: "StatusTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "StatusTableViewCell")
        tableView.register(UINib(nibName: "AddCardTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "AddCardTableViewCell")
        tableView.register(UINib(nibName: "InpuCardtRequisitesTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "InpuCardtRequisitesTableViewCell")

        tableView.dataSource = self
        tableView.delegate = self

        tableViewSection = [.cards, .addNew]

        if presentingViewController != nil, navigationController != nil, navigationController?.viewControllers.count == 1 {
            navigationItem.setRightBarButton(buttonClose, animated: true)
        }
        
        cardsController.addListener(self)
        loadCards()
    }

    @objc func closeView(_: UIBarButtonItem?) {
        if let presetingVC = presentingViewController {
            presetingVC.dismiss(animated: true) {
                //
            }
        } else {
            if let nav = navigationController {
                nav.popViewController(animated: true)
            } else {
                dismiss(animated: true) {
                    //
                }
            }
        }
    }
    
    private func loadCards() {
        state = .loading
        cardsController.loadCards { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.cards = self.cardsController.getCards(predicates: .activeCards)
                self.state = .data
            case let .failure(error):
                self.cards = []
                self.state = .error(error)
            }
        }
    }

    private func cardListCell(for tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .loading:
            if indexPath.row < cards.count, let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCardTableViewCell") as? PaymentCardTableViewCell {
                let card = cards[indexPath.row]

                cell.labelCardName.text = card.pan
                cell.labelCardExpData.text = card.expDateFormat()

                return cell
            } else if let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell") as? StatusTableViewCell {
                cell.labelStatus.text = AcqLoc.instance.localize("TinkoffAcquiring.text.status.loading")
                cell.labelStatus.isHidden = false
                cell.buttonUpdate.isHidden = true
                cell.activityIndicator.startAnimating()

                return cell
            }
        case .data:
            if cards.isEmpty {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell") as? StatusTableViewCell {
                    cell.labelStatus.text = AcqLoc.instance.localize("TinkoffAcquiring.text.status.cardListEmpty")
                    cell.labelStatus.isHidden = false
                    cell.buttonUpdate.isHidden = true
                    cell.activityIndicator.stopAnimating()

                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCardTableViewCell") as? PaymentCardTableViewCell {
                    let card = cards[indexPath.row]

                    cell.labelCardName.text = card.pan
                    cell.labelCardExpData.text = card.expDateFormat()
                    cardRequisitesBrandInfo.cardBrandInfo(numbers: card.pan, completion: { [weak cell] requisites, icon, _ in
                        if let numbers = requisites, card.pan.hasPrefix(numbers) {
                            cell?.imageViewLogo.image = icon
                            cell?.imageViewLogo.isHidden = false
                        } else {
                            cell?.imageViewLogo.image = nil
                            cell?.imageViewLogo.isHidden = true
                        }
                    })

                    return cell
                }
            }
        case let .error(error):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell") as? StatusTableViewCell {
                if (error as NSError).code == 7 {
                    cell.labelStatus.text = error.localizedDescription
                } else {
                    cell.labelStatus.text = AcqLoc.instance.localize("TinkoffAcquiring.text.status.cardListEmpty")
                }

                cell.labelStatus.isHidden = false
                cell.buttonUpdate.isHidden = false
                cell.activityIndicator.stopAnimating()
                cell.onButtonTouch = { [weak self] in
                    self?.loadCards()
                }

                return cell
            }
        }
        
        return tableView.defaultCell()
    }

    private func showAlert(for result: Result<PaymentCard?, Error>) {
        var alertTitle: String
        var alertMessage: String?
        var alertIcon: AcquiringAlertIconType

        switch result {
        case let .success(card):
            if let cardAdded = card {
                alertTitle = AcqLoc.instance.localize("TinkoffAcquiring.alert.title.cardSuccessAdded")
                alertMessage = "card id = \(cardAdded.cardId),\n\(cardAdded.pan) \(cardAdded.expDateFormat() ?? "")"
                alertIcon = .success
            } else {
                alertTitle = AcqLoc.instance.localize("TinkoffAcquiring.alert.title.addingCard")
                alertMessage = AcqLoc.instance.localize("TinkoffAcquiring.alert.message.addingCardCancel")
                alertIcon = .error
            }

        case let .failure(error):
            alertTitle = AcqLoc.instance.localize("TinkoffAcquiring.alert.title.error")
            alertMessage = error.localizedDescription
            alertIcon = .error
        }

        if let alert = alertViewHelper?.presentAlertView(alertTitle, message: alertMessage, dismissCompletion: nil) {
            present(alert, animated: true, completion: nil)
        } else {
            let alert = AcquiringAlertViewController.create()
            alert.present(on: self, title: alertTitle, icon: alertIcon)
        }
    }

    private func showAddCardView() {
        // create
        let modalViewController = AddNewCardViewController(nibName: "PopUpViewContoller", bundle: Bundle(for: AddNewCardViewController.self))
        modalViewController.cardsController = cardsController
        modalViewController.scanerDataSource = scanerDataSource
        modalViewController.alertViewHelper = alertViewHelper

        modalViewController.addCardCheckType = { [weak self] in
            self?.addCardNeedSetCheckTypeHandler?() ?? .no
        }
        modalViewController.onCardAddFinished = { [weak self] result in
            self?.showAlert(for: result)
        }

        // present
        let presentationController = PullUpPresentationController(presentedViewController: modalViewController, presenting: self)
        modalViewController.transitioningDelegate = presentationController
        present(modalViewController, animated: true, completion: {
            _ = presentationController
        })
    }

    private func checkIfCellIsEditable(at indexPath: IndexPath) -> Bool {
        guard case .cards = tableViewSection[indexPath.section],
              case .data = state
        else { return false }
        return true
    }
}

extension CardsViewController: UITableViewDelegate {
    // MARK: UITableViewDelegate - Swipe actions

    func tableView(_: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch tableViewSection[indexPath.section] {
        case .addNew:
            return .none

        case .cards:
            return .delete
        }
    }

    // MARK: UITableViewDelegate - Selection

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableViewSection[indexPath.section] {
        case .addNew:
            showAddCardView()
        case .cards:
            break
        }
    }

    // MARK: UITableViewDelegate - Editing

    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: AcqLoc.instance.localize("TinkoffAcquiring.button.delete")) { _, indexPath in
            self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
            return
        }

        return [deleteButton]
    }
}

extension CardsViewController: UITableViewDataSource {
    // MARK: UITableViewDataSource

    func numberOfSections(in _: UITableView) -> Int {
        return tableViewSection.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewSection[section] {
        case .addNew:
            return 1

        case .cards:
            switch state {
            case .loading:
                return 1 + cards.count
            case .data:
                if cards.isEmpty {
                    return 1
                } else {
                    return cards.count
                }
            case .error:
                return 1
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewSection[indexPath.section] {
        case .addNew:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AddCardTableViewCell") as? AddCardTableViewCell {
                return cell
            }

        case .cards:
            return cardListCell(for: tableView, cellForRowAt: indexPath)
        }

        return tableView.defaultCell()
    }

    // MARK: TableViewDataSource - Editing

    func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        checkIfCellIsEditable(at: indexPath)
    }

    func tableView(_: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, commit _: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch tableViewSection[indexPath.section] {
        case .addNew:
            break

        case .cards:
            print("TODO: Deactivate card via controller")
            // TODO: TODO: Deactivate card via controller
        } // switch tableViewSection
    }
}

extension CardsViewController: CardsControllerListener {
    func cardsControllerDidUpdateCards(_ cardsController: CardsController) {
        self.cards = cardsController.getCards(predicates: .activeCards)
        self.tableView.reloadData()
    }
}
