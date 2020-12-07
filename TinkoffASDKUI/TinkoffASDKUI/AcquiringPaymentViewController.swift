//
//  AcquiringPaymentViewController.swift
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

/// получение информации для отрисовки списка карт
protocol AcquiringCardListDataSourceDelegate: class {
    func customerKey() -> String
    /// Количество доступных, активных карт
    func cardListNumberOfCards() -> Int
    /// Статус обновления списока карт
    func cardListFetchStatus() -> FetchStatus<[PaymentCard]>
    /// Получить карту
    func cardListCard(at index: Int) -> PaymentCard
    /// Получить карту по cardId
    func cardListCard(with cardId: String) -> PaymentCard?
    /// Получить карту по parentPaymentId
    func cardListCard(with parentPaymentId: Int64) -> PaymentCard?
    /// Перезагрузить, обновить список карт
    func cardListReloadData()
    /// Деактивировать карту
    func cardListDeactivateCard(at index: Int, startHandler: (() -> Void)?, completion: ((PaymentCard?) -> Void)?)
    /// Добавить карту
    func cardListAddCard(number: String, expDate: String, cvc: String, addCardViewPresenter: AcquiringView, alertViewHelper: AcquiringAlertViewProtocol?, completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void)
    /// Показать экран добавления карты
    func presentAddCardView(on presentingViewController: UIViewController, customerKey: String, configuration: AcquiringViewConfiguration, completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void)
}

enum AcquiringViewStatus {
    /// инициализация платежа
    case initWaiting
    /// `PaimentId` получен, форма готова к оплате
    case ready
    case paymentWaiting(status: String?)
    /// для сгенерированного QR-кода в виде `url` ожидается оплата
    case paymentWaitingSBPQrCode(qrCode: String, status: String?)
    /// для сгенерированного QR-кода в виде `image` ожидается оплата
    case paymentWaitingSBPUrl(url: String, status: String?)
    /// статический qr-код для приема платежей
    case qrCodeStatic(qrCode: String, title: String?)
    /// для оплаты требуется ввести реквизиты карты CVC
    case paymentWainingCVC(cardParentId: Int64)
    /// нет возможности оплатить, отображаем ошибку
    case error(Error)
}

enum AcquiringViewTableViewCells {
    case amount(title: NSAttributedString, amount: NSAttributedString)
    case productDetail(title: NSAttributedString)
    case cardList
    case error
    case waitingPaymentQrCode(qrCode: String, status: String?)
    case waitingPaymentURL(url: String, status: String?)
    case qrCodeStatic(qrCode: String, title: String?)
    case waitingPayment
    case waitingInitPayment
    case empty(height: Int)
    case buttonPay
    case separatorLabel
    case buttonPaySBP
    case secureLogos
    case email(value: String?, placeholder: String)
}

protocol AcquiringView: class {
    func setCells(_ value: [AcquiringViewTableViewCells])

    func changedStatus(_ status: AcquiringViewStatus)

    func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>)

    func setViewHeight(_ height: CGFloat)

    func closeVC(animated flag: Bool, completion: (() -> Void)?)

    func presentVC(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)

    func checkDeviceFor3DSData(with request: URLRequest)

    var onTouchButtonShowCardList: (() -> Void)? { get set }
    var onTouchButtonPay: (() -> Void)? { get set }
    var onTouchButtonSBP: (() -> Void)? { get set }
    var onCancelPayment: (() -> Void)? { get set }
    ///
    func cardRequisites() -> PaymentSourceData?
    func infoEmail() -> String?
}

class AcquiringPaymentViewController: PopUpViewContoller {
    // MARK: AcquiringView

    var onTouchButtonShowCardList: (() -> Void)?
    var onTouchButtonPay: (() -> Void)?
    var onTouchButtonSBP: (() -> Void)?
    var onCancelPayment: (() -> Void)?

    // MARK: IBOutlets

    @IBOutlet private var webView: WKWebView!

    private var paymentStatus: AcquiringViewStatus = .initWaiting {
        didSet {
            updateTableViewCells()
        }
    }

    private var tableViewCells: [AcquiringViewTableViewCells] = []
    private var userTableViewCells: [AcquiringViewTableViewCells] = []

    private lazy var cardListPresenter: CardListViewOutConnection = CardListPresenter()
    private lazy var inputEmailPresenter: InputEmailControllerOutConnection = InputEmailController()

    weak var cardListDataSourceDelegate: AcquiringCardListDataSourceDelegate?
    weak var scanerDataSource: AcquiringScanerProtocol?
    weak var alertViewHelper: AcquiringAlertViewProtocol?

    // MARK: Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        registerCells(["ScrollableTableViewCell",
                       "ButtonTableViewCell",
                       "StatusTableViewCell",
                       "ResistanceSpaceTableViewCell",
                       "QRCodeWebTableViewCell",
                       "QRCodeImageTableViewCell",
                       "AmountTableViewCell",
                       "PSLogoTableViewCell",
                       "LabelTableViewCell",
                       "TextFieldTableViewCell"], for: tableView)

        tableViewCells = [.waitingInitPayment]
        tableView.dataSource = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        cardListDataSourceDelegate = nil
        onCancelPayment?()
    }

    override func updateView() {
        super.updateView()

        cardListPresenter.updateView()
    }

    override func pushToNavigationStackAndActivate(firstResponder textField: UIView?, completion _: (() -> Void)? = nil) -> Bool {
        let tmpCardListDataSourceDelegate = cardListDataSourceDelegate
        let tmpOnCancelPayment = onCancelPayment
        onCancelPayment = nil

        return super.pushToNavigationStackAndActivate(firstResponder: textField) {
            self.cardListDataSourceDelegate = tmpCardListDataSourceDelegate
            if tmpOnCancelPayment != nil {
                self.onCancelPayment = tmpOnCancelPayment
            }
        }
    }

    private func registerCells(_ names: [String], for table: UITableView) {
        names.forEach { name in
            table.register(UINib(nibName: name, bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: name)
        }
    }

    func setupTableViewCellForPayment() {
        userTableViewCells.forEach { item in
            if case AcquiringViewTableViewCells.buttonPaySBP = item {
            } else {
                tableViewCells.append(item)
            }
        }

        tableViewCells.append(.cardList)
        tableViewCells.append(.buttonPay)

        if userTableViewCells.first(where: { (item) -> Bool in
            if case AcquiringViewTableViewCells.buttonPaySBP = item { return true }
            return false
        }) != nil {
            tableViewCells.append(.separatorLabel)
            tableViewCells.append(.buttonPaySBP)
        }

        tableViewCells.append(.secureLogos)
        tableViewCells.append(.empty(height: 44))
    }

    private func updateTableViewCells() {
        tableViewCells = []
        viewWaiting.isHidden = true

        switch paymentStatus {
        case .initWaiting:
            tableViewCells.append(.waitingInitPayment)

        case .error:
            tableViewCells.append(.error)

        case let .qrCodeStatic(qrCode, title):
            tableViewCells.append(.qrCodeStatic(qrCode: qrCode, title: title))

        case .paymentWainingCVC:
            userTableViewCells.forEach { item in
                if case AcquiringViewTableViewCells.buttonPaySBP = item {
                } else {
                    tableViewCells.append(item)
                }
            }

            tableViewCells.append(.cardList)
            tableViewCells.append(.buttonPay)
            tableViewCells.append(.secureLogos)
            tableViewCells.append(.empty(height: 44))

        case .ready:
            setupTableViewCellForPayment()

        case .paymentWaiting:
            viewWaiting.isHidden = false
            setupTableViewCellForPayment()

        case let .paymentWaitingSBPQrCode(qrCode, status):
            tableViewCells.append(.waitingPaymentQrCode(qrCode: qrCode, status: status))

        case let .paymentWaitingSBPUrl(url, status):
            tableViewCells.append(.waitingPaymentURL(url: url, status: status))
        }

        tableView.reloadData()
    }

    func validatePaymentForm(showErrorStatus: Bool = true) -> Bool {
        if userTableViewCells.first(where: { (item) -> Bool in
            if case AcquiringViewTableViewCells.email = item { return true }
            return false
        }) != nil {
            let result = inputEmailPresenter.inputValue() != nil

            if result == false, showErrorStatus == true {
                inputEmailPresenter.setStatus(.error, statusText: nil)
            }

            return result
        }

        switch cardListPresenter.requisies() {
        case let .savedCard(card, cvc):
            let cardRequisitesValidator: CardRequisitesValidatorProtocol = CardRequisitesValidator()

            if card.parentPaymentId == nil {
                if cardRequisitesValidator.validateCardCVC(cvc: cvc) {
                    return true
                }
            } else if case .paymentWainingCVC = paymentStatus {
                if cardRequisitesValidator.validateCardCVC(cvc: cvc) {
                    return true
                }
            }

            cardListPresenter.setStatus(.error, statusText: nil)
            return false

        case let .requisites(number, expDate, cvc):
            if let number = number, let expDate = expDate, let cvc = cvc {
                let cardRequisitesValidator: CardRequisitesValidatorProtocol = CardRequisitesValidator()
                if cardRequisitesValidator.validateCardNumber(number: number), cardRequisitesValidator.validateCardExpiredDate(value: expDate), cardRequisitesValidator.validateCardCVC(cvc: cvc) {
                    return true
                } else {
                    cardListPresenter.setStatus(.error, statusText: nil)
                    return false
                }
            } else {
                cardListPresenter.setStatus(.error, statusText: nil)
                return false
            }
        }

        return true
    }
}

extension AcquiringPaymentViewController: UITableViewDataSource {
    // MARK: UITableViewDataSource

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return tableViewCells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableViewCells[indexPath.row] {
        case let .amount(title, amount):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AmountTableViewCell") as? AmountTableViewCell {
                cell.labelTitle.attributedText = title
                cell.labelAmount.attributedText = amount

                return cell
            }

        case let .productDetail(text):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTableViewCell") as? LabelTableViewCell {
                cell.labelTitle.attributedText = text

                return cell
            }

        case .cardList:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ScrollableTableViewCell") as? ScrollableTableViewCell {
                cardListPresenter.presentCardList(dataSource: cardListDataSourceDelegate,
                                                  in: cell,
                                                  becomeFirstResponderListener: self,
                                                  scaner: scanerDataSource != nil ? self : nil)

                if case let .paymentWainingCVC(parentPaymentId) = paymentStatus {
                    self.viewWaiting.isHidden = false
                    cardListPresenter.waitCVCInput(forCardWith: parentPaymentId) {
                        self.viewWaiting.isHidden = true
                    }
                }

                cardListPresenter.didSelectSBPItem = { [weak self] in
                    _ = self?.pushToNavigationStackAndActivate(firstResponder: nil)
                }

                cardListPresenter.didSelectShowCardList = { [weak self] in
                    self?.onTouchButtonShowCardList?()
                }

                return cell
            }

        case .error:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell") as? StatusTableViewCell {
                cell.labelStatus.text = AcqLoc.instance.localize("TinkoffAcquiring.unknown.error.status")
                cell.labelStatus.isHidden = false
                cell.buttonUpdate.isHidden = true
                cell.activityIndicator.stopAnimating()
                if case let .error(error) = paymentStatus {
                    cell.labelStatus.text = error.localizedDescription
                }

                return cell
            }

        case let .waitingPaymentQrCode(qrCode, status):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "QRCodeWebTableViewCell") as? QRCodeWebTableViewCell {
                cell.labelTitle.text = status
                cell.showQRCode(data: qrCode)
                cell.buttonShare.isHidden = true

                return cell
            }

        case let .waitingPaymentURL(url, _):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "QRCodeImageTableViewCell") as? QRCodeImageTableViewCell {
                cell.imageViewIcon?.image = UIImage(qr: url)

                return cell
            }

        case let .qrCodeStatic(qrCode, title):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "QRCodeWebTableViewCell") as? QRCodeWebTableViewCell {
                cell.labelTitle.text = title
                cell.showQRCode(data: qrCode)
                cell.buttonShare.isHidden = true

                return cell
            }

        case .waitingPayment:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell") as? StatusTableViewCell {
                cell.labelStatus.text = AcqLoc.instance.localize("TinkoffAcquiring.text.status.waitingPayment")
                cell.buttonUpdate.isHidden = true

                return cell
            }

        case .waitingInitPayment:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell") as? StatusTableViewCell {
                cell.labelStatus.text = AcqLoc.instance.localize("TinkoffAcquiring.text.status.waitingInitPayment")
                cell.buttonUpdate.isHidden = true

                return cell
            }

        case .empty:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ResistanceSpaceTableViewCell") as? ResistanceSpaceTableViewCell {
                cell.setHeight(90)

                return cell
            }

        case .separatorLabel:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTableViewCell") as? LabelTableViewCell {
                cell.labelTitle.textAlignment = .center
                cell.labelTitle.text = AcqLoc.instance.localize("TinkoffAcquiring.text.or")

                return cell
            }

        case .buttonPay:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell") as? ButtonTableViewCell {
                cell.buttonAction.setTitle(AcqLoc.instance.localize("TinkoffAcquiring.button.payByCard"), for: .normal)
                cell.buttonAction.tintColor = UIColor(hex: "#333333")
                cell.buttonAction.backgroundColor = UIColor(hex: "#FFDD2D")

                cell.onButtonTouch = { [weak self] in
                    if self?.validatePaymentForm() ?? false {
                        self?.onTouchButtonPay?()
                    }
                }

                return cell
            }

        case .buttonPaySBP:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell") as? ButtonTableViewCell {
                cell.buttonAction.setTitle(AcqLoc.instance.localize("TinkoffAcquiring.button.payBy"), for: .normal)
                cell.buttonAction.tintColor = UIColor.dynamic.button.sbp.tint
                cell.buttonAction.backgroundColor = UIColor.dynamic.button.sbp.background
                cell.setButtonIcon(UIImage(named: "buttonIconSBP", in: Bundle(for: type(of: self)), compatibleWith: nil))

                cell.onButtonTouch = { [weak self] in
                    if self?.validatePaymentForm() ?? false {
                        self?.onTouchButtonSBP?()
                    }
                }

                return cell
            }

        case .secureLogos:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PSLogoTableViewCell") as? PSLogoTableViewCell {
                return cell
            }

        case let .email(value, placeholder):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as? TextFieldTableViewCell {
                inputEmailPresenter.present(hint: placeholder,
                                            preFilledValue: value,
                                            textFieldCell: cell,
                                            tableView: tableView,
                                            firstResponderListener: self)

                return cell
            }
        }

        return tableView.defaultCell()
    }
}

extension AcquiringPaymentViewController: BecomeFirstResponderListener {
    // MARK: BecomeFirstResponderListener

    func textFieldShouldBecomeFirstResponder(_ textField: UITextField) -> Bool {
        return pushToNavigationStackAndActivate(firstResponder: textField)
    }
}

extension AcquiringPaymentViewController: CardRequisitesScanerProtocol {
    func startScanner(completion: @escaping (String?, Int?, Int?) -> Void) {
        if let scanerView = scanerDataSource?.presentScanner(completion: { numbers, mm, yy in
            completion(numbers, mm, yy)
        }) {
            presentVC(scanerView, animated: true, completion: nil)
        }
    }
}

extension AcquiringPaymentViewController: AcquiringView {
    // MARK: AcquiringView

    func changedStatus(_ status: AcquiringViewStatus) {
        paymentStatus = status
    }

    func cardsListUpdated(_: FetchStatus<[PaymentCard]>) {
        if tableViewCells.first(where: { (item) -> Bool in
            if case .cardList = item { return true }
            return false
        }) != nil {
            cardListPresenter.updateView()
        }
    }

    func setViewHeight(_ height: CGFloat) {
        modalMinHeight = height
        preferredContentSize = CGSize(width: preferredContentSize.width, height: height)
    }

    func closeVC(animated _: Bool, completion: (() -> Void)?) {
        cardListDataSourceDelegate = nil
        onCancelPayment = nil
        closeViewController {
            completion?()
        }
    }

    func presentVC(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        let tmpCardListDataSourceDelegate = cardListDataSourceDelegate
        let tmpOnCancelPayment = onCancelPayment
        onCancelPayment = nil

        present(viewControllerToPresent, animated: flag, completion: {
            self.cardListDataSourceDelegate = tmpCardListDataSourceDelegate
            self.onCancelPayment = tmpOnCancelPayment
            completion?()
        })
    }

    // MARK: Setup View

    func setCells(_ value: [AcquiringViewTableViewCells]) {
        userTableViewCells = value
    }

    func checkDeviceFor3DSData(with request: URLRequest) {
        webView.load(request)
    }

    func cardRequisites() -> PaymentSourceData? {
        switch cardListPresenter.requisies() {
        case let .savedCard(card, cvv):
            return PaymentSourceData.savedCard(cardId: card.cardId, cvv: cvv)

        case let .requisites(number, expDate, cvc):
            if let number = number, let expDate = expDate, let cvc = cvc {
                let cardRequisitesValidator: CardRequisitesValidatorProtocol = CardRequisitesValidator()
                if cardRequisitesValidator.validateCardNumber(number: number), cardRequisitesValidator.validateCardExpiredDate(value: expDate), cardRequisitesValidator.validateCardCVC(cvc: cvc) {
                    return PaymentSourceData.cardNumber(number: number, expDate: expDate, cvv: cvc)
                }
            }
        }

        return nil
    }

    func infoEmail() -> String? {
        if userTableViewCells.first(where: { (item) -> Bool in
            if case AcquiringViewTableViewCells.email = item { return true }
            return false
        }) != nil {
            return inputEmailPresenter.inputValue()
        }

        return nil
    }
}
