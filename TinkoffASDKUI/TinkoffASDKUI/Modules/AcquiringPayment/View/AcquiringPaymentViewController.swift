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
protocol AcquiringCardListDataSourceDelegate: AnyObject {
    /// Количество доступных, активных карт
    func getCardListNumberOfCards() -> Int
    /// Статус обновления списока карт
    func getCardListFetchStatus() -> FetchStatus<[PaymentCard]>
    /// Получить карту
    func getCardListCard(at index: Int) -> PaymentCard
    /// Получить карту по cardId
    func getCardListCard(with cardId: String) -> PaymentCard?
    /// Получить карту по parentPaymentId
    func getCardListCard(with parentPaymentId: Int64) -> PaymentCard?
    /// Получить все карты
    func getAllCards() -> [PaymentCard]
    /// Перезагрузить, обновить список карт
    func cardListReload()
    /// Деактивировать карту
    func cardListToDeactivateCard(at index: Int, startHandler: (() -> Void)?, completion: ((PaymentCard?) -> Void)?)
    /// Добавить карту
    func cardListToAddCard(number: String, expDate: String, cvc: String, addCardViewPresenter: AcquiringView, alertViewHelper: AcquiringAlertViewProtocol?, completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void)
    /// Показать экран добавления карты
    func presentAddCard(on presentingViewController: UIViewController, customerKey: String, configuration: AcquiringViewConfiguration, completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void)
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
    case chooseAnotherCard
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
    case email(value: String?, placeholder: String)
    case tinkoffPay
}

protocol AcquiringView: AnyObject {
    func setCells(_ value: [AcquiringViewTableViewCells])

    func changedStatus(_ status: AcquiringViewStatus)

    func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>)

    func setViewHeight(_ height: CGFloat)

    func closeVC(animated flag: Bool, completion: (() -> Void)?)

    func presentVC(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)

    func checkDeviceFor3DSData(with request: URLRequest)

    var onTouchButtonShowCardList: (() -> Void)? { get set }
    var onTouchButtonPay: (() -> Void)? { get set }
    var onTouchButtonSBP: ((UIViewController) -> Void)? { get set }
    var onTinkoffPayButton: ((GetTinkoffPayStatusResponse.Status.Version, UIViewController) -> Void)? { get set }
    var onCancelPayment: (() -> Void)? { get set }
    var onInitFinished: ((Result<Int64, Error>) -> Void)? { get set }
    ///
    func cardRequisites() -> PaymentSourceData?
    func infoEmail() -> String?
    
    func setPaymentType(_ paymentType: PaymentType)
}

extension AcquiringView {
    func setPaymentType(_ paymentType: PaymentType) {}
    var onInitFinished: ((Result<Int64, Error>) -> Void)? {
        get { nil }
        set {}
    }

    var onTinkoffPayButton: ((GetTinkoffPayStatusResponse.Status.Version, UIViewController) -> Void)? {
        get { nil }
        set {}
    }
}

class AcquiringPaymentViewController: PopUpViewContoller {
    // MARK: Style
    
    struct Style {
        let payButtonStyle: ButtonStyle
        let tinkoffPayButtonStyle: TinkoffPayButton.DynamicStyle
    }
    
    var style: Style?
    
    // MARK: AcquiringView

    var onTouchButtonShowCardList: (() -> Void)?
    var onTouchButtonPay: (() -> Void)?
    var onTouchButtonSBP: ((UIViewController) -> Void)?
    var onTinkoffPayButton: ((GetTinkoffPayStatusResponse.Status.Version, UIViewController) -> Void)?
    var onCancelPayment: (() -> Void)?
    var onInitFinished: ((Result<Int64, Error>) -> Void)?

    // MARK: IBOutlets

    @IBOutlet private var webView: WKWebView!


    private var paymentStatus: AcquiringViewStatus = .initWaiting {
        didSet {
            updateTableViewCells()
        }
    }
    
    private var paymentType: PaymentType = .standard {
        didSet {
            cardListController.setPaymentType(paymentType)
        }
    }

    private var tableViewCells: [AcquiringViewTableViewCells] = []
    private var userTableViewCells: [AcquiringViewTableViewCells] = []

    private lazy var cardListController: CardListViewOutConnection = CardListController()
    private lazy var inputEmailPresenter: InputEmailControllerOutConnection = InputEmailController()

    weak var cardListDataSourceDelegate: AcquiringCardListDataSourceDelegate?
    weak var scanerDataSource: AcquiringScanerProtocol?
    weak var alertViewHelper: AcquiringAlertViewProtocol?
    
    var acquiringPaymentController: AcquiringPaymentController?
    var tinkoffPayStatus: GetTinkoffPayStatusResponse.Status?

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
                       "LabelTableViewCell",
                       "TextFieldTableViewCell"], for: tableView)
        tableView.register(ContainerTableViewCell.self,
                           forCellReuseIdentifier: ContainerTableViewCell.reuseIdentifier)

        tableViewCells = [.waitingInitPayment]
        tableView.dataSource = self
        
        acquiringPaymentController?.loadCardsAndCheckTinkoffPayAvailability()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        cardListDataSourceDelegate = nil
        onCancelPayment?()
    }

    override func updateView() {
        super.updateView()

        cardListController.updateView()
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
            table.register(UINib(nibName: name, bundle: .uiResources), forCellReuseIdentifier: name)
        }
    }

    func setupTableViewCellForPayment() {
        userTableViewCells.forEach { item in
            if case AcquiringViewTableViewCells.buttonPaySBP = item {}
            else if case AcquiringViewTableViewCells.tinkoffPay = item {}
            else {
                tableViewCells.append(item)
            }
        }

        tableViewCells.append(.cardList)
        if paymentType == .standard,
           (cardListDataSourceDelegate?.getCardListNumberOfCards() ?? .zero) > .zero {
            tableViewCells.append(.chooseAnotherCard)
        }

        tableViewCells.append(.buttonPay)
        
        if userTableViewCells.first(where: { (item) -> Bool in
            if case AcquiringViewTableViewCells.buttonPaySBP = item { return true }
            return false
        }) != nil {
            tableViewCells.append(.buttonPaySBP)
        }
        
        var isTinkoffPayEnabled = userTableViewCells.first(where: { item -> Bool in
            if case AcquiringViewTableViewCells.tinkoffPay = item { return true } else { return false } })
        != nil

        switch tinkoffPayStatus {
        case .allowed(_):
            isTinkoffPayEnabled = isTinkoffPayEnabled && true
        default:
            isTinkoffPayEnabled = false
        }
        
        if isTinkoffPayEnabled {
            tableViewCells.append(.tinkoffPay)
        }
        
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

            if !result, showErrorStatus {
                inputEmailPresenter.setStatus(.error, statusText: nil)
            }

            return result
        }

        switch cardListController.requisites() {
        case let .savedCard(_, cvc):
            let cardRequisitesValidator: ICardRequisitesValidator = CardRequisitesValidator()
            
            var validationResult = true
            
            if case .paymentWainingCVC = paymentStatus {
                validationResult = cardRequisitesValidator.validate(inputCVC: cvc)
            } else {
                switch paymentType {
                case .standard:
                    validationResult = cardRequisitesValidator.validate(inputCVC: cvc)
                case .recurrent:
                    validationResult = true
                }
            }
            
            if !validationResult {
                cardListController.setStatus(.error, statusText: nil)
            }
            return validationResult

        case let .requisites(number, expDate, cvc):
            if let number = number, let expDate = expDate, let cvc = cvc {
                let cardRequisitesValidator: ICardRequisitesValidator = CardRequisitesValidator()
                if cardRequisitesValidator.validate(inputPAN: number),
                   cardRequisitesValidator.validate(inputValidThru: expDate),
                   cardRequisitesValidator.validate(inputCVC: cvc) {
                    return true
                } else {
                    cardListController.setStatus(.error, statusText: nil)
                    return false
                }
            } else {
                cardListController.setStatus(.error, statusText: nil)
                return false
            }
        }
    }
    
    @objc private func handleTinkoffPayButtonTouch(sender: TinkoffPayButton) {
        guard case let .allowed(version: version) = tinkoffPayStatus else { return }
        onTinkoffPayButton?(version, self)
    }

    @objc private func sbpButtonTapped() {
        onTouchButtonSBP?(self)
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
                cardListController.presentCardList(dataSource: cardListDataSourceDelegate,
                                                  in: cell,
                                                  becomeFirstResponderListener: self,
                                                  scanner: scanerDataSource != nil ? self : nil)

                if case let .paymentWainingCVC(parentPaymentId) = paymentStatus {
                    self.viewWaiting.isHidden = false
                    cardListController.waitCVCInput(forCardWith: parentPaymentId) {
                        self.viewWaiting.isHidden = true
                    }
                }

                cardListController.didSelectSBPItem = { [weak self] in
                    _ = self?.pushToNavigationStackAndActivate(firstResponder: nil)
                }

                cardListController.didSelectShowCardList = { [weak self] in
                    self?.onTouchButtonShowCardList?()
                }

                return cell
            }
        case .chooseAnotherCard:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ContainerTableViewCell.reuseIdentifier
            ) as? ContainerTableViewCell  else {
                break
            }
            let linkView = LinkTappingView(title: L10n.AcquiringPayment.Button.chooseCard)
            linkView.onButtonTap = { [weak self] in self?.onTouchButtonShowCardList?() }
            cell.setContent(linkView, insets: .cardsLinkView)
            return cell
        case .error:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell") as? StatusTableViewCell {
                cell.labelStatus.text = L10n.TinkoffAcquiring.Unknown.Error.status
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
                cell.labelStatus.text = L10n.TinkoffAcquiring.Text.Status.waitingPayment
                cell.buttonUpdate.isHidden = true

                return cell
            }

        case .waitingInitPayment:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell") as? StatusTableViewCell {
                cell.labelStatus.text = L10n.TinkoffAcquiring.Text.Status.waitingInitPayment
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
                cell.labelTitle.text = L10n.TinkoffAcquiring.Text.or
                return cell
            }

        case .buttonPay:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell") as? ButtonTableViewCell {
                cell.buttonAction.setTitle(L10n.TinkoffAcquiring.Button.payByCard, for: .normal)
                if let style = style {
                    cell.buttonAction.tintColor = style.payButtonStyle.titleColor
                    cell.buttonAction.backgroundColor = style.payButtonStyle.backgroundColor
                } else {
                    assertionFailure("must inject style via property")
                }

                cell.onButtonTouch = { [weak self] in
                    guard let self = self,
                          self.validatePaymentForm() else { return }

                    let action = self.onTouchButtonPay ?? self.acquiringPaymentController?.performPayment
                    action?()
                }

                return cell
            }

        case .buttonPaySBP:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContainerTableViewCell.reuseIdentifier) as? ContainerTableViewCell else {
                break
            }
            let button = ASDKButton(style: .sbpPayment)
            button.addTarget(self, action: #selector(sbpButtonTapped), for: .touchUpInside)
            cell.setContent(button, insets: .buttonInContainerInsets)
            return cell
        case let .email(value, placeholder):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell") as? TextFieldTableViewCell {
                inputEmailPresenter.present(hint: placeholder,
                                            preFilledValue: value,
                                            textFieldCell: cell,
                                            tableView: tableView,
                                            firstResponderListener: self)

                return cell
            }
        case .tinkoffPay:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: ContainerTableViewCell.reuseIdentifier
            ) as? ContainerTableViewCell {
                
                let btn: TinkoffPayButton
                if let style = style {
                    btn = TinkoffPayButton(dynamicStyle: style.tinkoffPayButtonStyle)
                } else {
                    btn = TinkoffPayButton()
                }
                
                btn.addTarget(self,
                              action: #selector(handleTinkoffPayButtonTouch),
                              for: .touchUpInside)
                cell.setContent(btn, insets: .buttonInContainerInsets)
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

extension AcquiringPaymentViewController: ICardRequisitesScanner {
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
        guard tableViewCells.contains(where: \.isCardList) else { return }
        cardListController.updateView()
        updateTableViewCells()
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

    func presentVC(
        _ viewControllerToPresent: UIViewController,
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        let tmpCardListDataSourceDelegate = cardListDataSourceDelegate
        let tmpOnCancelPayment = onCancelPayment
        onCancelPayment = nil

        present(viewControllerToPresent, animated: animated, completion: {
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
        switch cardListController.requisites() {
        case let .savedCard(card, cvv):
            return PaymentSourceData.savedCard(cardId: card.cardId, cvv: cvv)

        case let .requisites(number, expDate, cvc):
            if let number = number, let expDate = expDate, let cvc = cvc {
                let cardRequisitesValidator: ICardRequisitesValidator = CardRequisitesValidator()
                if cardRequisitesValidator.validate(inputPAN: number),
                   cardRequisitesValidator.validate(inputValidThru: expDate),
                   cardRequisitesValidator.validate(inputCVC: cvc) {
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
    
    func setPaymentType(_ paymentType: PaymentType) {
        self.paymentType = paymentType
    }

    func selectCard(withId cardId: String) {
        cardListController.selectCard(withId: cardId)
    }

    func selectRequisitesInput() {
        cardListController.selectRequisitesInput()
    }
}

extension AcquiringPaymentViewController: AcquiringPaymentControllerDelegate {
    func acquiringPaymentController(_ acquiringPaymentController: AcquiringPaymentController,
                                    didUpdateCards status: FetchStatus<[PaymentCard]>) {
        cardsListUpdated(status)
    }
    
    func acquiringPaymentController(_ acquiringPaymentController: AcquiringPaymentController,
                                    didUpdateTinkoffPayAvailability status: GetTinkoffPayStatusResponse.Status) {
        tinkoffPayStatus = status
    }
    
    func acquiringPaymentControllerDidFinishPreparation(_ acquiringPaymentController: AcquiringPaymentController) {
        paymentStatus = .ready
    }
    
    func acquiringPaymentController(_ acquiringPaymentController: AcquiringPaymentController,
                                    didPaymentInitWith result: Result<Int64, Error>) {
        onInitFinished?(result)
    }
}

// MARK: - UIEdgeInsets + Constants

private extension UIEdgeInsets {
    static var buttonInContainerInsets: UIEdgeInsets {
        UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 20)
    }

    static var cardsLinkView: UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 20, bottom: 12, right: 20)
    }
}

// MARK: - AcquiringViewTableViewCells + Helpers

private extension AcquiringViewTableViewCells {
    var isCardList: Bool {
        guard case .cardList = self else {
            return false
        }

        return true
    }
}
