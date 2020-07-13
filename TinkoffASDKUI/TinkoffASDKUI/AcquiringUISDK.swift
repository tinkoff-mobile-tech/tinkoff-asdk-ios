//
//  AcquiringUISDK.swift
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
import TinkoffASDKCore
import WebKit
import PassKit

public class AcquiringViewConfigration {
	///
	/// Поля на форме оплаты
	public enum InfoFields {
		/// Информация о товаре, заголовок и цена
		case amount(title: NSAttributedString, amount: NSAttributedString)
		/// описание товара
		case detail(title: NSAttributedString)
		/// поле ввода email, куда выслать чек - результат оплаты
		case email(value: String?, placeholder: String)
		/// показывать кнопку оплаты Системы Быстрых Платежей
		case buttonPaySPB
	}
	
	public struct FeaturesOptions {
		var fpsEnabled: Bool = false
		
		init() {}
	}
	///
	/// Локализация формы оплаты
	public struct LocalizableInfo {
		var table: String?
		var bundle: Bundle?
		var lang: String?
		
		public init(lang: String?) {
			self.lang = lang
		}
		
		public init(table: String?, bundle: Bundle?) {
			self.table = table
			self.bundle = bundle
		}
	}
	
	public var localizableInfo: LocalizableInfo?
	
	///  Сканер
	public weak var scaner: AcquiringScanerProtocol?
	///
	public weak var alertViewHelper: AcquiringAlertViewProtocol?
	
	public var featuresOptions = FeaturesOptions()
	public var fields: [InfoFields] = []
	public var viewTitle: String?
	public var startViewHeight: CGFloat?
	
	public init() {}
}


public typealias PaymentCompletionHandler = ((_ result: Result<PaymentStatusResponse, Error>) -> Void)
public typealias AddCardCompletionHandler = ((_ result: Result<AddCardStatusResponse, Error>) -> Void)

/// Сканер для реквизитов карты
public protocol AcquiringScanerProtocol: class {
	///
	/// - Parameters:
	///   - completion: результат сканирования, номер карты `number`, год `yy`, месяц `mm`
	/// - Returns: сканер UIViewController
	func presentScanner(completion: @escaping (_ number: String?, _ yy: Int?, _ mm: Int?) -> Void) -> UIViewController?
	
}

/// Отображение не стандартного AlertView если в приложении используется не UIAlertViewController
public protocol AcquiringAlertViewProtocol: class {
	///
	/// - Parameters:
	///   - title: заголовок
	///   - message: описание
	///   - completion: блок для уведомления что алерт закрыли
	/// - Returns: алерт UIViewController
	func presentAlertView(_ title: String?, message: String?, dismissCompletion: (() -> Void)?) -> UIViewController?
	
}


///
public class AcquiringUISDK: NSObject {

	private weak var presentingViewController: UIViewController?
	//
	private var acquiringSdk: AcquiringSdk
	private weak var acquiringPaymentView: AcquiringViewConfiguration?
	private weak var cardsListView: CardListDataSourceStatusListener?
	//
	private var startPaymentInitData: PaymentInitData?
	private var initResponse: PaymentInitResponse?
	private var onPaymentCompletionHandler: PaymentCompletionHandler?
	private var finishPaymentStatusResponse: Result<PaymentStatusResponse, Error>?
	
	// 3ds web view Checking
	private weak var webViewController: WebViewController?
	private var webView3DSCheckingTerminationUrl: String?
	private var on3DSCheckingCompletionHandler: PaymentCompletionHandler?
	private var on3DSCheckingAddCardCompletionHandler: AddCardCompletionHandler?
	// random amount
	private var onRandomAmountCheckingAddCardCompletionHandler: AddCardCompletionHandler?

	// data providers
	private var cardListDataProvider: CardListDataProvider!
	private var checkPaymentStatus: PaymentStatusServiceProvider?
	
	public init(configuration: AcquiringSdkConfiguration) throws {
		self.acquiringSdk = try AcquiringSdk.init(configuration: configuration)
	}
	
	/// Вызывается кода пользователь привязывается карту.
	/// Нужно указать с каким методом привязывать карту, по умолчанию `PaymentCardCheckType.no` - на усмотрение сервера
	public var addCardNeedSetCheckTypeHandler: (() -> PaymentCardCheckType)?
	
	private func createCardListView() -> CardsViewController {
		let viewController = CardsViewController(nibName: "CardsViewController", bundle: Bundle(for: CardsViewController.self))
		viewController.cardListDataSourceDelegate = self
		
		return viewController
	}
	
	public func setupCardListDataProvider(for customer: String, statusListener: CardListDataSourceStatusListener? = nil) {
		if cardListDataProvider != nil && cardListDataProvider.customerKey != customer {
			cardListDataProvider = CardListDataProvider.init(sdk: acquiringSdk, customerKey: customer)
		} else if cardListDataProvider ==  nil {
			cardListDataProvider = CardListDataProvider.init(sdk: acquiringSdk, customerKey: customer)
		}
		
		if statusListener == nil {
			cardListDataProvider.dataSourceStatusListener = self
		} else {
			cardListDataProvider.dataSourceStatusListener = statusListener
		}
	}
	
	public func presentCardList(on presentingViewController: UIViewController, customerKey: String, configuration: AcquiringViewConfigration) {
		AcqLoc.instance.setup(lang: configuration.localizableInfo?.lang, table: configuration.localizableInfo?.table, bundle: configuration.localizableInfo?.bundle)

		self.presentingViewController = presentingViewController
		// create
		let modalViewController = createCardListView()
		modalViewController.scanerDataSource = configuration.scaner
		modalViewController.alertViewHelper = configuration.alertViewHelper
		
		setupCardListDataProvider(for: customerKey)
		cardsListView = modalViewController
		// present
		let presentationController = UINavigationController.init(rootViewController: modalViewController)
		presentingViewController.present(presentationController, animated: true) {
			_ = presentationController
			self.cardListDataProvider.update()
		}
	}
	
	
	///
	/// С помощью экрана оплаты используя реквизиты карты или ранее сохраненную карту
	public func presentPaymentView(on presentingViewController: UIViewController,
								   paymentData: PaymentInitData,
								   configuration: AcquiringViewConfigration,
								   completionHandler: @escaping PaymentCompletionHandler)
	{
		onPaymentCompletionHandler = completionHandler
		
		presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: paymentData.customerKey, configuration: configuration) { view in
			self.startPay(paymentData)
		}
		
		acquiringPaymentView?.onTouchButtonPay = { [weak self] in
			if let cardRequisites = self?.acquiringPaymentView?.cardRequisites(), let paymentId = self?.initResponse?.paymentId {
				self?.finishPay(cardRequisites: cardRequisites, paymentId: paymentId, infoEmail: self?.acquiringPaymentView?.infoEmail())
			}
		}
		
		acquiringPaymentView?.onTouchButtonSBP = { [weak self] in
			if let paymentId = self?.initResponse?.paymentId {
				self?.presentSbpActivity(paymentId: paymentId, paymentInvoiceSource: .url)
			}
		}
		
	}
	
	///
	/// Оплатить на основе родительского платежа, регулярный платеж
	public func presentPaymentView(on presentingViewController: UIViewController,
								   paymentData: PaymentInitData,
								   parentPatmentId: Int64,
								   configuration: AcquiringViewConfigration,
								   completionHandler: @escaping PaymentCompletionHandler)
	{
		onPaymentCompletionHandler = completionHandler
		startChargeWith(paymentData, parentPaymentId: parentPatmentId,
						presentingViewController: presentingViewController,
						configuration: configuration)
	}
	
	// MARK: Система Быстрых Платежей
	
	/// Проверить есть ли возможность оплаты с помощью СБП
	public func canMakePaymentsSBP() -> Bool {
		return acquiringSdk.fpsEnabled
	}
		
	public func presentPaymentSbpQrImage(on presentingViewController: UIViewController, paymentData: PaymentInitData, configuration: AcquiringViewConfigration, completionHandler: @escaping PaymentCompletionHandler) {
		presentPaymentSbp(on: presentingViewController, paymentInvoiceSource: .imageSVG, paymentData: paymentData, configuration: configuration) { (response) in
			completionHandler(response)
		}
	}
	
	public func presentPaymentSbpUrl(on presentingViewController: UIViewController, paymentData: PaymentInitData, configuration: AcquiringViewConfigration, completionHandler: @escaping PaymentCompletionHandler) {
		presentPaymentSbp(on: presentingViewController, paymentInvoiceSource: .url, paymentData: paymentData, configuration: configuration) { (response) in
			completionHandler(response)
		}
	}
	
	private func presentPaymentSbp(on presentingViewController: UIViewController, paymentInvoiceSource: PaymentInvoiceSBPSourceType, paymentData: PaymentInitData, configuration: AcquiringViewConfigration, completionHandler: @escaping PaymentCompletionHandler) {
		onPaymentCompletionHandler = completionHandler
		
		presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: paymentData.customerKey, configuration: configuration) { view in
			self.initPay(paymentData: paymentData) { [weak self] (response) in
				switch response {
					case .success(let initResponse):
						self?.initResponse = initResponse
						self?.presentSbpActivity(paymentId: initResponse.paymentId, paymentInvoiceSource: paymentInvoiceSource)
					
					case .failure(let error):
						self?.initResponse = nil
						DispatchQueue.main.async {
							self?.acquiringPaymentView?.closeVC(animated: true) {
								completionHandler(.failure(error))
							}
						}
				}
			}//initPay
		}
	}
	
	public func presentPaymentQRCollector(on presentingViewController: UIViewController, configuration: AcquiringViewConfigration) {
		onPaymentCompletionHandler = nil
		
		if configuration.startViewHeight == nil {
			configuration.startViewHeight = presentingViewController.view.frame.size.width + 80
		}
		
		presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: nil, configuration: configuration) { view in
			let viewTitle = AcqLoc.instance.localize("TinkoffAcquiring.view.title.payQRCode")
			view.changedStatus(.initWaiting)
			self.getStaticQRCode { [weak self, weak view] (response) in
				switch response {
					case .success(let qrCodeSVG):
						DispatchQueue.main.async {
							view?.changedStatus(.qrCodeStatic(qrCode: qrCodeSVG.qrCodeData, title: viewTitle))
						}
					
					case .failure(let error):
						if let alertView = self?.alertView(for: error) {
							DispatchQueue.main.async {
								view?.closeVC(animated: true) {
									presentingViewController.present(alertView, animated: true, completion: nil)
								}
							}
						}
				}//switch response
			}//getStaticQRCode
		}
	}
	
	// MARK: ApplePay

	public struct ApplePayConfiguration {
		public var merchantIdentifier: String = "merchant.tcsbank.ApplePayTestMerchantId"
		public var supportedNetworks: [PKPaymentNetwork] = [PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]
		public var capabilties: PKMerchantCapability = PKMerchantCapability.init(arrayLiteral: .capability3DS, .capabilityCredit, .capabilityDebit)
		
		public var countryCode: String = "RU"
		public var currencyCode: String = "RUB"
		public var shippingContact: PKContact?
		public var billingContact: PKContact?
		
		public init() {}
	}
	
	public func canMakePaymentsApplePay(with configuration: ApplePayConfiguration) -> Bool {
		return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: configuration.supportedNetworks, capabilities: configuration.capabilties)
	}

	/// 'Creating Payment Requests' https://developer.apple.com/library/archive/ApplePay_Guide/CreateRequest.html#//apple_ref/doc/uid/TP40014764-CH3-SW2
	public func presentPaymentApplePay(on presentingViewController: UIViewController, paymentData data: PaymentInitData, viewConfiguration: AcquiringViewConfigration, paymentConfiguration: AcquiringUISDK.ApplePayConfiguration, completionHandler: @escaping PaymentCompletionHandler) {
		let request = PKPaymentRequest.init()
		request.merchantIdentifier = paymentConfiguration.merchantIdentifier
		request.supportedNetworks = paymentConfiguration.supportedNetworks
		request.merchantCapabilities = paymentConfiguration.capabilties
		request.countryCode = paymentConfiguration.countryCode
		request.currencyCode = paymentConfiguration.currencyCode
		request.shippingContact = paymentConfiguration.shippingContact
		request.billingContact = paymentConfiguration.billingContact
		
		request.paymentSummaryItems = [
			PKPaymentSummaryItem.init(label: data.description ?? "", amount: NSDecimalNumber.init(value: Double(data.amount) / Double(100.0) ))
		]
		
		self.presentingViewController = presentingViewController
		self.onPaymentCompletionHandler = completionHandler
		viewConfiguration.startViewHeight = 120
		
		presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: nil, configuration: viewConfiguration) { view in
			self.initPay(paymentData: data) { [weak self] (response) in
				switch response {
					case .success(let initResponse):
						self?.initResponse = initResponse
						DispatchQueue.main.async {
							self?.presentApplePayActivity(request)
						}
						
					case .failure(let error):
						self?.initResponse = nil
						DispatchQueue.main.async {
							self?.acquiringPaymentView?.closeVC(animated: true) {
								completionHandler(.failure(error))
							}
						}
				}
			}//initPay
		}
	}
	
	private func presentApplePayActivity(_ request: PKPaymentRequest) {
		guard let viewController = PKPaymentAuthorizationViewController.init(paymentRequest: request) else {
			self.acquiringPaymentView?.closeVC(animated: true) {
				let error = NSError(domain: AcqLoc.instance.localize("TinkoffAcquiring.unknown.response.status"),
									code: 0,
									userInfo: nil)
				
				self.onPaymentCompletionHandler?(.failure(error))
			}

			return
		}

		viewController.delegate = self
		
		acquiringPaymentView?.presentVC(viewController, animated: true) { //[weak self] in
			//self?.acquiringView.setViewHeight(viewController.view.frame.height)
		}
	}
	
	private func getStaticQRCode(completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeCollectorResponse, Error>) -> Void) {
		_ = acquiringSdk.paymentInvoiceQRCodeCollector(data: PaymentInvoiceSBPSourceType.imageSVG, completionHandler: { (response) in
			completionHandler(response)
		})
	}
	
	private func presentSbpActivity(paymentId: Int64, paymentInvoiceSource: PaymentInvoiceSBPSourceType) {
		let paymentInvoice = PaymentInvoiceQRCodeData.init(paymentId: paymentId, paymentInvoiceType: paymentInvoiceSource)
		_ = acquiringSdk.paymentInvoiceQRCode(data: paymentInvoice) { [weak self] (response) in
			switch response {
				case .success(let qrCodeResponse):
					DispatchQueue.main.async {
						if paymentInvoiceSource == .url, let url = URL.init(string: qrCodeResponse.qrCodeData) {
							if UIApplication.shared.canOpenURL(url) {
								UIApplication.shared.open(url, options: [:]) { (completion) in
									self?.sbpWaitingIncominPayment(paymentId: paymentId, source: qrCodeResponse.qrCodeData, sourceType: paymentInvoiceSource)
									self?.acquiringPaymentView?.changedStatus(.paymentWaitingSBPUrl(url: qrCodeResponse.qrCodeData, status: "Выбор источника оплаты"))
								}
							} else {
								let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
								activityViewController.excludedActivityTypes = [.postToWeibo, .print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .airDrop, .openInIBooks, .markupAsPDF]
								
								activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
									self?.sbpWaitingIncominPayment(paymentId: paymentId, source: qrCodeResponse.qrCodeData, sourceType: paymentInvoiceSource)
								}
								
								self?.acquiringPaymentView?.presentVC(activityViewController, animated: true, completion: {
									self?.acquiringPaymentView?.changedStatus(.paymentWaitingSBPUrl(url: qrCodeResponse.qrCodeData, status: "Выбор источника оплаты"))
								})
							}
						} else {
							self?.sbpWaitingIncominPayment(paymentId: paymentId, source: qrCodeResponse.qrCodeData, sourceType: paymentInvoiceSource)
						}
					}
					
				case .failure(let error):
					self?.initResponse = nil
					DispatchQueue.main.async {
						self?.acquiringPaymentView?.changedStatus(.error(error))
						self?.showErrorAlert(error: error)
					}
			}
		}
	}

	private func sbpWaitingIncominPayment(paymentId: Int64, source: String, sourceType: PaymentInvoiceSBPSourceType) {
		let completionStatus: [PaymentStatus] = [.confirmed, .checked3ds, .refunded, .reversed, .rejected]
		let completionHandler = onPaymentCompletionHandler
		
		checkPaymentStatus = PaymentStatusServiceProvider.init(sdk: acquiringSdk, paymentId: paymentId)
		checkPaymentStatus?.onStatusUpdated = { [weak self] (fetchStatus) in
			switch fetchStatus {
				case .object(let response):
					if completionStatus.contains(response.status) {
						self?.acquiringPaymentView?.closeVC(animated: true, completion: {
							completionHandler?(.success(response))
						})
					}
					
				default:
					break
			}
		}
		
		if sourceType == .url {
			acquiringPaymentView?.changedStatus(.paymentWaitingSBPUrl(url: source, status: "Ожидание оплаты"))
		} else {
			acquiringPaymentView?.changedStatus(.paymentWaitingSBPQrCode(qrCode: source, status: "Ожидание оплаты"))
		}
		
		checkPaymentStatus?.fetchStatus(completionStatus: completionStatus)
	}
	
	// MARK: Create and Setup AcquiringViewController
	
	private func presentAcquiringPaymentView(presentingViewController: UIViewController,
											 customerKey: String?,
											 configuration: AcquiringViewConfigration,
											 onPresenting: @escaping ((AcquiringViewConfiguration) -> Void) )
	{
		self.presentingViewController = presentingViewController
		AcqLoc.instance.setup(lang: configuration.localizableInfo?.lang, table: configuration.localizableInfo?.table, bundle: configuration.localizableInfo?.bundle)

		// create
		let modalViewController = AcquiringPaymentViewController(nibName: "AcquiringPaymentViewController", bundle: Bundle(for: AcquiringPaymentViewController.self))
		
		var fields: [AcquiringViewTableViewCells] = []
		
		var estimatedViewHeight: CGFloat = 300
		
		if let startViewHeight = configuration.startViewHeight {
			estimatedViewHeight = startViewHeight
		}
		
		configuration.fields.forEach { (field) in
			switch field {
				case .amount(let title, let amount):
					fields.append(.amount(title: title, amount: amount))
					estimatedViewHeight += 50
				case .detail(let title):
					fields.append(.productDetail(title: title))
					estimatedViewHeight += 50
				case .buttonPaySPB:
					fields.append(.buttonPaySBP)
					estimatedViewHeight += 120
				case .email(let value, let placeholder):
					fields.append(.email(value: value, placeholder: placeholder))
					estimatedViewHeight += 64
			}
		}
		
		modalViewController.modalMinHeight = estimatedViewHeight
		modalViewController.setCells(fields)
		
		modalViewController.cardListDataSourceDelegate = self
		modalViewController.scanerDataSource = configuration.scaner
		modalViewController.alertViewHelper = configuration.alertViewHelper
		
		acquiringPaymentView = modalViewController
		modalViewController.onTouchButtonShowCardList = { [weak self] in
			if let viewController = self?.createCardListView() {
				viewController.scanerDataSource = modalViewController.scanerDataSource
				viewController.alertViewHelper = modalViewController.alertViewHelper
				self?.cardsListView = viewController
				
				let cardListNController = UINavigationController.init(rootViewController: viewController)
				if self?.acquiringPaymentView != nil {
					self?.acquiringPaymentView?.presentVC(cardListNController, animated: true, completion: nil)
				} else {
					self?.presentingViewController?.present(cardListNController, animated: true, completion: nil)
				}
			}
		}
		
		modalViewController.onCancelPayment = { [weak self] in
			self?.cancelPayment()
		}
		
		// setup
		if let key = customerKey {
			setupCardListDataProvider(for: key)
			cardListDataProvider.update()
		}
		
		// present
		let presentationController = PullUpPresentationController(presentedViewController: modalViewController, presenting: presentingViewController)
		modalViewController.transitioningDelegate = presentationController
		presentingViewController.present(modalViewController, animated: true, completion: {
			_ = presentationController
			onPresenting(modalViewController)
		})
	}
	
	// MARK: Payment
	
	private func startPay(_ initPaymentData: PaymentInitData) {
		startPaymentInitData = initPaymentData
		initPay(paymentData: initPaymentData) { [weak self] (response) in
			switch response {
				case .success(let initResponse):
					self?.initResponse = initResponse
					DispatchQueue.main.async {
						self?.acquiringPaymentView?.changedStatus(.ready)
					}
					
				case .failure(let error):
					self?.initResponse = nil
					DispatchQueue.main.async {
						self?.acquiringPaymentView?.closeVC(animated: true) {
							self?.onPaymentCompletionHandler?(.failure(error))
						}
					}
			}
		}//initPay
	}
	
	private func initPay(paymentData: PaymentInitData, completionHandler: @escaping (_ result: Result<PaymentInitResponse, Error>) -> Void) {
		acquiringPaymentView?.changedStatus(.initWaiting)
		_ = acquiringSdk.paymentInit(data: paymentData) { (response) in
			completionHandler(response)
		}
	}

	/// Для сценария когда при прохождении 3ds v2 произошла ошибка.
	/// Инициируем новый платеж и и завершаем его без проверки версии 3ds, те если потребуется прохождение топрохолим по версии 1.0
	private func paymentTryAgainWith3dsV1(_ data: PaymentInitData, completionHandler: @escaping PaymentCompletionHandler) {
		initResponse = nil
		initPay(paymentData: data) { [weak self] (initResponse) in
			switch initResponse {
				case .success(let successResponse):
					// завершаем оплату
					DispatchQueue.main.async {
						if let cardRequisites = self?.acquiringPaymentView?.cardRequisites() {
							var requestData = PaymentFinishRequestData.init(paymentId: successResponse.paymentId, paymentSource: cardRequisites)
							requestData.setInfoEmail(self?.acquiringPaymentView?.infoEmail())
							
							self?.finishAuthorize(requestData: requestData, treeDSmessageVersion: "1.0", completionHandler: { (finishResponse) in
								completionHandler(finishResponse)
							})
						}
					}
				
				case .failure(let error):
					completionHandler(.failure(error))
			}
		}//initPay
	}
	
	// MARK: Charge
	
	private func startChargeWith(_ paymentData: PaymentInitData,
								 parentPaymentId: Int64,
								 presentingViewController: UIViewController,
								 configuration: AcquiringViewConfigration)
	{
		var data = paymentData
		data.addPaymentData(["chargeFlag": "true"])
		
		_ = acquiringSdk.paymentInit(data: data) { (initResponse) in
			switch initResponse {
				case .success(let successInitResponse):
					self.initResponse = successInitResponse
					DispatchQueue.main.async {
						let chargeData = PaymentChargeRequestData.init(paymentId: successInitResponse.paymentId, parentPatemntId: parentPaymentId)
						_ = self.acquiringSdk.chargePayment(data: chargeData, completionHandler: { (chargeResponse) in
							switch chargeResponse {
								case .success(let successChargeResponse):
									DispatchQueue.main.async { [weak self] in
										if self?.acquiringPaymentView != nil {
											self?.acquiringPaymentView?.closeVC(animated: true, completion: {
												self?.onPaymentCompletionHandler?(.success(successChargeResponse))
											})
										} else {
											self?.onPaymentCompletionHandler?(.success(successChargeResponse))
										}
									}
								
								case .failure(let error):
									if (error as NSError).code == 104 {
										data.addPaymentData(["failMapiSessionId": "\(successInitResponse.paymentId)"])
										data.addPaymentData(["recurringType": "12"])
										data.savingAsParentPayment = true
										DispatchQueue.main.async {
											var chargePaymentId = successInitResponse.paymentId
											self.presentAcquiringPaymentView(presentingViewController: presentingViewController, customerKey: nil, configuration: configuration) { view in
												self.acquiringPaymentView?.changedStatus(.initWaiting)
												self.initPay(paymentData: data, completionHandler: { (initResponse) in
													switch initResponse {
														case .success(let initResponseSuccess):
															self.initResponse = successInitResponse
															DispatchQueue.main.async { [weak self] in
																chargePaymentId = initResponseSuccess.paymentId
																self?.acquiringPaymentView?.changedStatus(.paymentWainingCVC(cardParentId: parentPaymentId))
														}
														
														case .failure(let error):
															DispatchQueue.main.async { [weak self] in
																self?.acquiringPaymentView?.closeVC(animated: true) {
																	self?.onPaymentCompletionHandler?(.failure(error))
																}
														}
													}
												})
												
												self.acquiringPaymentView?.onTouchButtonPay = { [weak self] in
													if let cardRequisites = self?.acquiringPaymentView?.cardRequisites() {
														self?.finishPay(cardRequisites: cardRequisites, paymentId: chargePaymentId, infoEmail: self?.acquiringPaymentView?.infoEmail())
													}
												}
											}
										}
									} else {
										DispatchQueue.main.async { [weak self] in
											if self?.acquiringPaymentView != nil {
												self?.acquiringPaymentView?.closeVC(animated: true, completion: {
													self?.onPaymentCompletionHandler?(.failure(error))
												})
											} else {
												self?.onPaymentCompletionHandler?(.failure(error))
											}
										}
									}
							}//chargeResponse
						})//charge finish
					}
				
				case .failure(let error):
					self.initResponse = nil
					DispatchQueue.main.async { [weak self] in
						if self?.acquiringPaymentView != nil {
							self?.acquiringPaymentView?.closeVC(animated: true, completion: {
								self?.onPaymentCompletionHandler?(.failure(error))
							})
						} else {
							self?.onPaymentCompletionHandler?(.failure(error))
						}
					}
			}//switch initResponse
		}//acquiringSdk.paymentInit
	}//startChargeWith
	

	// MARK: FinishPay & Finish Authorize
	
	private func finishPay(cardRequisites: PaymentSourceData, paymentId: Int64, infoEmail: String?) {
		var requestData = PaymentFinishRequestData.init(paymentId: paymentId, paymentSource: cardRequisites)
		requestData.setInfoEmail(infoEmail)
		acquiringPaymentView?.changedStatus(.paymentWaiting(status: nil))

		let completion = onPaymentCompletionHandler
		check3dsVersionAndFinishAuthorize(requestData: requestData) { [weak self] (response) in
			switch response {
				case .success(let paymentResponse):
					DispatchQueue.main.async { [weak self] in
						self?.acquiringPaymentView?.closeVC(animated: true) {
							completion?(.success(paymentResponse))
						}
					}
				
				case .failure(let error):
					DispatchQueue.main.async { [weak self] in
						self?.acquiringPaymentView?.closeVC(animated: true) {
							completion?(.failure(error))
						}
					}
			}
		}
	}
	
	private func finishAuthorize(requestData: PaymentFinishRequestData, treeDSmessageVersion: String, completionHandler: @escaping PaymentCompletionHandler) {
		_ = acquiringSdk.paymentFinish(data: requestData, completionHandler: { (response) in
			switch response {
			case .success(let finishResult):
				switch finishResult.responseStatus {
				case .needConfirmation3DS(let confirmation3DSData):
					DispatchQueue.main.async {
						self.on3DSCheckingCompletionHandler = { (response) in
							completionHandler(response)
						}
						
						self.present3DSChecking(with: confirmation3DSData, presenter: self.acquiringPaymentView) { [weak self] in
							self?.cancelPayment()
						}
					}
					
				case .needConfirmation3DSACS(let confirmation3DSDataACS):
					DispatchQueue.main.async {
						self.on3DSCheckingCompletionHandler = { (response) in
							completionHandler(response)
						}
						
						self.present3DSCheckingACS(with: confirmation3DSDataACS, messageVersion: treeDSmessageVersion, presenter: self.acquiringPaymentView) { [weak self] in
							self?.cancelPayment()
						}
					}
					
				case .done(let response):
					completionHandler(.success(response))
					
				case .unknown:
					let error = NSError(domain: finishResult.errorMessage ?? AcqLoc.instance.localize("TinkoffAcquiring.unknown.response.status"),
										code: finishResult.errorCode,
										userInfo: nil)
					
					completionHandler(.failure(error))
				
			}//case .success
			
			case .failure(let error):
				if (error as NSError).code == 106 {
					if let paymentInitData = self.startPaymentInitData {
						DispatchQueue.main.async {
							self.paymentTryAgainWith3dsV1(paymentInitData) { (response) in
								completionHandler(response)
							}
						}
					}
				} else {
					completionHandler(.failure(error))
				}
			}//switch response
		})//paymentFinish
		
	}
	
	private func check3dsVersionAndFinishAuthorize(requestData: PaymentFinishRequestData, completionHandler: @escaping PaymentCompletionHandler) {
		_ = acquiringSdk.check3dsVersion(data: requestData, completionHandler: { (checkResponse) in
			switch checkResponse {
				case .success(let checkResult):
					var finistRequestData = requestData
					// сбор информации для прохождения 3DS v2
					if let tdsServerTransID = checkResult.tdsServerTransID, let threeDSMethodURL = checkResult.threeDSMethodURL {
						// вызываем web view для проверки девайса
						self.threeDSMethodCheckURL(tdsServerTransID: tdsServerTransID, threeDSMethodURL: threeDSMethodURL, notificationURL: self.acquiringSdk.confirmation3DSCompleteV2URL().absoluteString)
						// собираем информацию о девайсе
						let screenSize = UIScreen.main.bounds.size
						let deviceInfo = DeviceInfoParams.init(cresCallbackUrl: self.acquiringSdk.confirmation3DSTerminationV2URL().absoluteString,
															   languageId: self.acquiringSdk.languageKey?.rawValue ?? "ru"	,
															   screenWidth: Int(screenSize.width),
															   screenHeight: Int(screenSize.height))
						finistRequestData.setDeviceInfo(info: deviceInfo)
						finistRequestData.setThreeDSVersion(checkResult.version)
						finistRequestData.setIpAddress(self.acquiringSdk.networkIpAddress())
					}
					// завершаем оплату
					self.finishAuthorize(requestData: finistRequestData, treeDSmessageVersion: checkResult.version) { (finishResponse) in
						completionHandler(finishResponse)
					}
				
				case .failure(let error):
					completionHandler(.failure(error))
			}
		})
	}
	
	private func threeDSMethodCheckURL(tdsServerTransID: String, threeDSMethodURL: String, notificationURL: String) {
		let urlData = Checking3DSURLData.init(tdsServerTransID: tdsServerTransID, threeDSMethodURL: threeDSMethodURL, notificationURL: notificationURL)
		guard let request = try? acquiringSdk.createChecking3DSURL(data: urlData) else {
			return
		}
		
		DispatchQueue.main.async { [weak self] in
			self?.acquiringPaymentView?.checkDeviceFor3DSData(with: request)
		}
	}
	
	private func cancelPayment() {
		if let orderId = initResponse?.orderId, let paymentId = initResponse?.paymentId, let amount = initResponse?.amount {
			let paymentResponse = PaymentStatusResponse.init(success: false,
															 errorCode: 0,
															 errorMessage: nil,
															 orderId: orderId,
															 paymentId: paymentId,
															 amount: amount,
															 status: .cancelled)
			onPaymentCompletionHandler?(.success(paymentResponse))
		}
	}
	
	private func cancelAddCard() {
		onRandomAmountCheckingAddCardCompletionHandler?(.success(AddCardStatusResponse.init(success: false, errorCode: 0)))
	}
	
	private func present3DSChecking(with data: Confirmation3DSData, presenter: AcquiringViewConfiguration?, onCancel: @escaping (() -> Void)) {
		guard let request = try? acquiringSdk.createConfirmation3DSRequest(data: data) else {
			return
		}
		
		let viewController = WebViewController(nibName: "WebViewController", bundle: Bundle(for: WebViewController.self))
		webViewController = viewController
		viewController.onCancel = {
			presenter?.closeVC(animated: true) {
				onCancel()
			}
		}
		
		presenter?.presentVC(UINavigationController.init(rootViewController: viewController), animated: true, completion: {
			viewController.webView.navigationDelegate = self
			viewController.webView.load(request)
		})
		
	}
	
	private func present3DSCheckingACS(with data: Confirmation3DSDataACS, messageVersion: String, presenter: AcquiringViewConfiguration?, onCancel: @escaping (() -> Void)) {
		guard let request = try? acquiringSdk.createConfirmation3DSRequestACS(data: data, messageVersion: messageVersion) else {
			return
		}
		
		let viewController = WebViewController(nibName: "WebViewController", bundle: Bundle(for: WebViewController.self))
		webViewController = viewController
		viewController.onCancel = {
			presenter?.closeVC(animated: true) {
				onCancel()
			}
		}
		
		presenter?.presentVC(UINavigationController.init(rootViewController: viewController), animated: true, completion: {
			viewController.webView.navigationDelegate = self
			viewController.webView.load(request)
		})
		
	}
	
	private func presentRandomAmounChecking(with requestKey: String, presenter: AcquiringViewConfiguration?, onCancel: @escaping (() -> Void)) {
		let viewController = RandomAmounCheckingViewController(nibName: "RandomAmounCheckingViewController", bundle: Bundle(for: RandomAmounCheckingViewController.self))
		
		viewController.onCancel = {
			onCancel()
		}
		
		viewController.completeHandler = { [weak self, weak viewController] (value) in
			viewController?.viewWaiting.isHidden = false
			self?.checkStateSubmitRandomAmount(amount: value, requestKey: requestKey, { (response) in
				DispatchQueue.main.async {
					viewController?.viewWaiting.isHidden = true
					switch response {
						case .success(_):
							viewController?.onCancel = nil
							viewController?.dismiss(animated: true, completion: {
								self?.onRandomAmountCheckingAddCardCompletionHandler?(response)
							})
						case .failure(let error):
							let alertView = UIAlertController.init(title: AcqLoc.instance.localize("TinkoffAcquiring.alert.title.error"), message: error.localizedDescription, preferredStyle: .alert)
							alertView.addAction(UIAlertAction.init(title: AcqLoc.instance.localize("TinkoffAcquiring.button.ok"), style: .default, handler: nil))
							viewController?.present(alertView, animated: true, completion: nil)
					}
					
				}
			})
		}
		
		presenter?.presentVC(UINavigationController.init(rootViewController: viewController), animated: true, completion: {
			
		})
	}
	
	// MARK: Error Alert
	
	private func showErrorAlert(error: Error) {
		let alertView = UIAlertController.init(title: AcqLoc.instance.localize("TinkoffAcquiring.alert.title.error"), message: error.localizedDescription, preferredStyle: .alert)
		alertView.addAction(UIAlertAction.init(title: AcqLoc.instance.localize("TinkoffAcquiring.button.ok"), style: .default, handler: { (_) in
			//
		}))
		
		presentingViewController?.present(alertView, animated: true, completion: {
			//
		})
	}

	private func alertView(for error: Error) -> UIAlertController {
		let alertView = UIAlertController.init(title: AcqLoc.instance.localize("TinkoffAcquiring.alert.title.error"), message: error.localizedDescription, preferredStyle: .alert)
		alertView.addAction(UIAlertAction.init(title: AcqLoc.instance.localize("TinkoffAcquiring.button.ok"), style: .default, handler: { (_) in
			//
		}))
		
		return alertView
	}
	
}


extension AcquiringUISDK: CardListDataSourceStatusListener {
	
	// MARK: CardListDataSourceStatusListener
	
	public func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>) {
		cardsListView?.cardsListUpdated(status)
		acquiringPaymentView?.cardsListUpdated(status)
	}
	
}


extension AcquiringUISDK: AcquiringCardListDataSourceDelegate {
		
	// MARK: AcquiringPaymentCardLidtDataSourceDelegate
	
	public func cardListNumberOfCards() -> Int {
		return cardListDataProvider.count()
	}
	
	public func cardListFetchStatus() -> FetchStatus<[PaymentCard]> {
		return cardListDataProvider.fetchStatus
	}
	
	public func cardListCard(at index: Int) -> PaymentCard {
		return cardListDataProvider.item(at: index)
	}
	
	public func cardListCard(with cardId: String) -> PaymentCard? {
		return cardListDataProvider.item(with: cardId)
	}
	
	public func cardListCard(with parentPaymentId: Int64) -> PaymentCard? {
		return cardListDataProvider.item(with: parentPaymentId)
	}
	
	public func cardListReloadData() {
		cardListDataProvider.update()
	}
	
	public func cardListDeactivateCard(at index: Int, startHandler: (() -> Void)?, completion: ((PaymentCard?) -> Void)?) {
		let card = cardListDataProvider.item(at: index)
		cardListDataProvider.deactivateCard(cardId: card.cardId, startHandler: {
			startHandler?()
		}) { (card) in
			completion?(card)
		}
	}
	
	private func checkConfirmAddCard(_ confirmationResponse: FinishAddCardResponse, presenter: AcquiringViewConfiguration, _ confirmationComplete: @escaping (Result<AddCardStatusResponse, Error>) -> Void) {
		switch confirmationResponse.responseStatus {
			case .needConfirmation3DS(let confirmation3DSData):
				on3DSCheckingAddCardCompletionHandler = { (response) in
					confirmationComplete(response)
				}
				
				present3DSChecking(with: confirmation3DSData, presenter: presenter) { [weak self] in
					self?.cancelAddCard()
				}
			
			case .needConfirmation3DSACS(let confirmation3DSDataACS):
				on3DSCheckingAddCardCompletionHandler = { (response) in
					confirmationComplete(response)
				}
				
				present3DSCheckingACS(with: confirmation3DSDataACS, messageVersion: "1.0", presenter: presenter) { [weak self] in
					self?.cancelAddCard()
				}
			
			case .needConfirmationRandomAmount(let requestKey):
				onRandomAmountCheckingAddCardCompletionHandler = { (response) in
					confirmationComplete(response)
				}
				
				presentRandomAmounChecking(with: requestKey, presenter: presenter) { [weak self] in
					self?.cancelAddCard()
				}
			
			case .done(let response):
				confirmationComplete(.success(response))
			
			case .unknown:
				let error = NSError(domain: confirmationResponse.errorMessage ?? AcqLoc.instance.localize("TinkoffAcquiring.unknown.response.status"),
									code: confirmationResponse.errorCode, userInfo: nil)
				
				confirmationComplete(.failure(error))
		}
	}
	
	private func checkStateSubmitRandomAmount(amount: Double, requestKey: String, _ confirmationComplete: @escaping (Result<AddCardStatusResponse, Error>) -> Void) {
		_ = acquiringSdk.chechRandomAmount(amount, requestKey: requestKey, responseDelegate: nil) { (response) in
			confirmationComplete(response)
		}
	}
	
	func cardListAddCard(number: String, expDate: String, cvc: String, addCardViewPresenter: AcquiringViewConfiguration, completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void) {
		
		let checkType: String
		if let value = addCardNeedSetCheckTypeHandler?() {
			checkType = value.rawValue
		} else {
			checkType = PaymentCardCheckType.no.rawValue
		}
		
		cardListDataProvider.addCard(number: number, expDate: expDate, cvc: cvc,
									 checkType: checkType,
		confirmationHandler: { (confirmationResponse, confirmationComplete) in
			DispatchQueue.main.async { [weak self] in
				self?.checkConfirmAddCard(confirmationResponse, presenter: addCardViewPresenter, confirmationComplete)
			}
		},
		completeHandler: { (response) in
			DispatchQueue.main.async {
				completeHandler(response)
			}
		})

	}

}

extension AcquiringUISDK: PKPaymentAuthorizationViewControllerDelegate {
	
	// MARK: PKPaymentAuthorizationViewControllerDelegate
	
	public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
		controller.dismiss(animated: true) {
			if let result = self.finishPaymentStatusResponse {
				self.acquiringPaymentView?.closeVC(animated: true) {
					self.onPaymentCompletionHandler?(result)
				}
			} else {
				self.acquiringPaymentView?.closeVC(animated: true) {
					self.cancelPayment()
				}
			}

		}
	}
	
	public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
												   didAuthorizePayment payment: PKPayment,
												   handler completion: @escaping (PKPaymentAuthorizationResult) -> Void)
	{
		if let paymentId = initResponse?.paymentId {
			let paymentDataSource = PaymentSourceData.paymentData(payment.token.paymentData.base64EncodedString())
			let data = PaymentFinishRequestData.init(paymentId: paymentId,
													 paymentSource: paymentDataSource,
													 source: "ApplePay",
													 route: "ACQ")

			finishAuthorize(requestData: data, treeDSmessageVersion: "1") { [weak self] (finishResponse) in
				switch finishResponse {
					case .failure(let error):
						DispatchQueue.main.async {
							completion(PKPaymentAuthorizationResult.init(status: .failure, errors: [error]))
						}
					
					case .success:
						DispatchQueue.main.async {
							completion(PKPaymentAuthorizationResult.init(status: .success, errors: nil))
						}
				}
				
				self?.finishPaymentStatusResponse = finishResponse
			} //self.finishAuthorize
		}
	}
	
}

extension AcquiringUISDK: WKNavigationDelegate {
	
	// MARK: WKNavigationDelegate
	
	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {		
		webView.evaluateJavaScript("document.baseURI") { [weak self] (value, error) in
			guard error == nil, let stringValue = value as? String else {
				return
			}
			
			guard stringValue.hasSuffix("cancel.do") == false else {
				self?.webViewController?.onCancel?()
				return
			}
			
			if stringValue.hasSuffix(self?.acquiringSdk.confirmation3DSTerminationURL().absoluteString ?? "") ||
				stringValue.hasSuffix(self?.acquiringSdk.confirmation3DSTerminationV2URL().absoluteString ?? "") {
				webView.evaluateJavaScript("document.getElementsByTagName('pre')[0].innerText") { (value, error) in
					debugPrint("document.getElementsByTagName('pre')[0].innerText = \(value ?? "" )")
// dubug success confirm add card
//					let value =
//"""
//{"Success":true,"ErrorCode":"0","TerminalKey":"TestSDK","Status":"AUTHORIZED","RequestKey":"9efaef1b-134c-4644-8e0c-b0e0609ddde4","CardId":"70000004024"}
//"""
// dubug success confirm payment
//					let value =
//"""
//{"Success":true,"ErrorCode":"0","TerminalKey":"TestSDK","Status":"AUTHORIZED","PaymentId":"700000417798","OrderId":"G-S/v6pDXvDh3JdM3wLC","Amount":100}
//"""
					guard let responseString = value as? String, let data = responseString.data(using: .utf8) else {
						return
					}
					
					self?.webViewController?.onCancel = nil
					
					// decode as a default `AcquiringResponse`
					guard let acquiringResponse = try? JSONDecoder().decode(AcquiringResponse.self, from: data) else {
						self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
							let error = NSError(domain: AcqLoc.instance.localize("TinkoffAcquiring.unknown.response.status"), code: 0, userInfo: nil)
							self?.on3DSCheckingCompletionHandler?(.failure(error))
							self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
						})
						
						return
					}
					
					// data  in `AcquiringResponse` format but `Success = 0;` ( `false` )
					guard acquiringResponse.success else {
						let error = NSError(domain: acquiringResponse.errorMessage ?? AcqLoc.instance.localize("TinkoffAcquiring.response.success.false"),
											code: acquiringResponse.errorCode,
											userInfo: try? acquiringResponse.encode2JSONObject())
						
						self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
							self?.on3DSCheckingCompletionHandler?(.failure(error))
							self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
						})

						return
					}
					
					// data in `PaymentStatusResponse` format
					if self?.on3DSCheckingCompletionHandler != nil {
						guard let responseObject: PaymentStatusResponse = try? JSONDecoder().decode(PaymentStatusResponse.self, from: data) else {
							let error = NSError(domain: acquiringResponse.errorMessage ?? AcqLoc.instance.localize("TinkoffAcquiring.response.success.false"),
												code: acquiringResponse.errorCode,
												userInfo: try? acquiringResponse.encode2JSONObject())
							
							self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
								self?.on3DSCheckingCompletionHandler?(.failure(error))
							})
							
							return
						}
						
						//
						self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
							self?.on3DSCheckingCompletionHandler?(.success(responseObject))
						})
					}
					
					// data in `AddCardStatusResponse` format
					if self?.on3DSCheckingAddCardCompletionHandler != nil {
						guard let responseObject: AddCardStatusResponse = try? JSONDecoder().decode(AddCardStatusResponse.self, from: data) else {
							let error = NSError(domain: acquiringResponse.errorMessage ?? AcqLoc.instance.localize("TinkoffAcquiring.response.success.false"),
												code: acquiringResponse.errorCode,
												userInfo: try? acquiringResponse.encode2JSONObject())
							
							self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
								self?.on3DSCheckingAddCardCompletionHandler?(.failure(error))
							})
							
							return
						}
						
						//
						self?.webViewController?.dismiss(animated: true, completion: { [weak self] in
							self?.on3DSCheckingAddCardCompletionHandler?(.success(responseObject))
						})
					}
					
				}//getElementsByTagName('pre')
			}//termURL.hasSuffix confirmation3DSTerminationURL
		}//document.baseURI
		
	}//func webView didFinish


}
