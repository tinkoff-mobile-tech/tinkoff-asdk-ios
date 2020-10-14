//
//  CardListDataProvider.swift
//  TinkoffASDKCore
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

import Foundation

/// Состояние для сервисов и объектов которые загружаем с севера
public enum FetchStatus<ObjectType> {
	/// статус -  пустое состояние, объект только создан, данных  нет
	case unknown
	/// статус -  данные загружаются
	case loading
	/// статус -  есть данные
	case object(ObjectType)
	/// статус -  данных нет
	case empty
	/// статус -  при загрузке данных произошла ошибка
	case error(Error)
	
}


/// Протокол загрузки объектов
public protocol FetchServiceProtocol {
	/// Тип объектов для загрузки
	associatedtype ObjectType
	
	/// Статус, текущее состояние сервиса
	var fetchStatus: FetchStatus<ObjectType> { get set }
	
	///
	/// - Parameters:
	///   - handlerOnStart: блок `(() -> Void)` сигнализирует о начале загрузки, используется уведомления пользователя что данные загружаются, можно обновить ui отрисовать SkeletonView
	///   - complete: `(ObjectType?, [Error]?)` загрузка данных завершена.
	func fetch(startHandler: (() -> Void)?, completeHandler: @escaping (ObjectType?, Error?) -> Void)
	
}


/// Обычно загружается массив объектов, чтобы получить доступ к dataSourrce использум протокол `FetchObjectsDataSourceProtocol`
/// Получение объектов загруженных с исползованием `FetchServiceProtocol`
public protocol FetchDataSourceProtocol: FetchServiceProtocol where ObjectType == [U] {
	///
	associatedtype U
	/// Общее колчесво объектов
	func count() -> Int
	/// Объект по индексу
	func item(at index: Int) -> U
	/// Объект по идентификатору
	func item(with identifier: String?) -> U?
	/// Объект по идентификатору
	func item(with parentPaymentIdentifier: Int64) -> U?
	
}


/// Для отслеживания состояния
public protocol CardListDataSourceStatusListener: class {
	/// Список карт обновился
	func cardsListUpdated(_ status: FetchStatus<[PaymentCard]>)
	
}


public final class CardListDataProvider: FetchDataSourceProtocol {

	public typealias ObjectType = [PaymentCard]
	
	public var fetchStatus: FetchStatus<[PaymentCard]> = .unknown {
		didSet {
			dataSourceStatusListener?.cardsListUpdated(fetchStatus)
		}
	}
	
	var queryStatus: Cancellable?
	
	private var activeCards: [PaymentCard] = []
	private var dataSource: [PaymentCard] = []
	private weak var sdk: AcquiringSdk?
	public private(set) var customerKey: String!
	public weak var dataSourceStatusListener: CardListDataSourceStatusListener?

	public func update() {
		switch fetchStatus {
		case .loading:
			break
		default:
			fetch(startHandler: nil) { (cards, errors) in }
		}
	}
	
	public init(sdk: AcquiringSdk?, customerKey: String) {
		self.sdk = sdk
		self.customerKey = customerKey
	}
	
	// MARK: Card List
	
	public func addCard(number: String, expDate: String, cvc: String, checkType: String,
						confirmationHandler: @escaping ((_ result: FinishAddCardResponse, _ confirmationComplete: @escaping (_ result: Result<AddCardStatusResponse, Error>) -> Void ) -> Void),
						completeHandler: @escaping (_ result: Result<PaymentCard?, Error>) -> Void) {
				
		// Step 1 init
		let initAddCardData = InitAddCardData.init(with: checkType, customerKey: customerKey)
		queryStatus = sdk?.сardListAddCardInit(data: initAddCardData, completionHandler: { [weak self] (responseInit) in
			switch responseInit {
			case .failure(let error):
				DispatchQueue.main.async { completeHandler(.failure(error)) }
			case .success(let initAddCardResponse):
				// Step 2 finish
				let finishData = FinishAddCardData.init(cardNumber: number, expDate: expDate, cvv: cvc, requestKey: initAddCardResponse.requestKey)
				self?.queryStatus = self?.sdk?.сardListAddCardFinish(data: finishData, responseDelegate: nil, completionHandler: { (responseFinish) in
					switch responseFinish {
					case .failure(let error):
						DispatchQueue.main.async { completeHandler(.failure(error)) }
					case .success(let finishAddCardResponse):
						// Step 3 complete
						confirmationHandler(finishAddCardResponse, { (completionResponse) in
							switch completionResponse {
								case .failure(let error):
									completeHandler(.failure(error))
								case .success(let confirmResponse):
									if let cardId = confirmResponse.cardId {
										self?.fetch(startHandler: nil, completeHandler: { (cards, error) in
											if let card = self?.item(with: cardId) {
												completeHandler(.success(card))
											} else if let card = self?.activeCards.last {
												completeHandler(.success(card))
											}
										})// fetch catrs list
									} else {
										completeHandler(.success(nil))
									}
							}
						})//confirmationHandler
					}
				})//сardListAddCardFinish
			}
		})//сardListAddCardInit
	}
		
	public func deactivateCard(cardId: String, startHandler: (() -> Void)?, completeHandler: @escaping (PaymentCard?) -> Void) {
		let initData = InitDeactivateCardData.init(cardId: cardId, customerKey: customerKey)
		
		startHandler?()
		
		queryStatus = sdk?.сardListDeactivateCard(data: initData, completionHandler: { [weak self] (response) in
			var status: FetchStatus<[PaymentCard]> = .loading
			var deactivatedCard: PaymentCard?
			switch response {
				case .failure(let error):
					status = FetchStatus.error(error)
				case .success(let cardResponse):
					if let cards = self?.dataSource.map({ (card) -> PaymentCard in
						if card.cardId == cardResponse.cardId {
							var deactivated = card
							deactivated.status = .deleted
							deactivatedCard = deactivated
							return deactivated
						}
						
						return card
					}) {
						self?.dataSource = cards
					}
					
					self?.activeCards = self?.dataSource.filter({ (card) -> Bool in
						return card.status == .active
					}) ?? []
					
					if let cards = self?.activeCards, cards.isEmpty == false {
						status = FetchStatus.object(cards)
					} else {
						status = FetchStatus.empty
					}
			}
			
			DispatchQueue.main.async {
				self?.fetchStatus = status
				completeHandler(deactivatedCard)
			}
		})
	}
	
	// MARK: FetchDataSourceProtocol
	
	public func fetch(startHandler: (() -> Void)?, completeHandler: @escaping ([PaymentCard]?, Error?) -> Void) {

		fetchStatus = .loading
		DispatchQueue.main.async { startHandler?() }

		let initGetCardListData = InitGetCardListData.init(customerKey: customerKey)
		queryStatus = sdk?.сardList(data: initGetCardListData, responseDelegate: self, completionHandler: { [weak self] (response) in
			var status: FetchStatus<[PaymentCard]> = .loading
			var responseError: Error?
			switch response {
				case .failure(let error):
					responseError = error
					status = FetchStatus.error(error)
				case .success(let cardListResponse):
					self?.dataSource = cardListResponse.cards
					let activeCards = cardListResponse.cards.filter({ (card) -> Bool in
						return card.status == .active
					})
					self?.activeCards = activeCards
					
					if activeCards.isEmpty {
						status = FetchStatus.empty
					} else {
						status = FetchStatus.object(activeCards)
					}
			}
			
			DispatchQueue.main.async {
				self?.fetchStatus = status
				completeHandler(self?.activeCards, responseError)
			}
		})
	}
	
	public func count() -> Int {
		return activeCards.count
	}
	
	public func item(at index: Int) -> PaymentCard {
		return activeCards[index]
	}
	
	public func item(with identifier: String?) -> PaymentCard? {
		return dataSource.first { (card) -> Bool in
			return card.cardId == identifier
		}
	}
	
	public func item(with parentPaymentId: Int64) -> PaymentCard? {
		return dataSource.first { (card) -> Bool in
			if let cardParentPaymentId = card.parentPaymentId {
				return parentPaymentId == cardParentPaymentId
			}
			
			return false
		}
	}
	
}


extension CardListDataProvider: NetworkTransportResponseDelegate {
	
	public func networkTransport(didCompleteRawTaskForRequest request: URLRequest, withData data: Data, response: URLResponse, error: Error?) throws -> ResponseOperation {
		let cardLidt = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
		
		var parameters: [String: Any] = [:]
		parameters.updateValue(true, forKey: "Success")
		parameters.updateValue(0, forKey: "ErrorCode")
		
		if let requestParamsData = request.httpBody, let requestParams = try JSONSerializationFormat.self.deserialize(data: requestParamsData) as? [String: Any] {
			if let terminalKey = requestParams["TerminalKey"] {
				parameters.updateValue(terminalKey, forKey: "TerminalKey")
			}
		}
		
		parameters.updateValue(cardLidt, forKey: "Cards")
		
		let cardData: Data = try JSONSerialization.data(withJSONObject: parameters, options: [.sortedKeys])
		
		return try JSONDecoder().decode(CardListResponse.self, from: cardData)
	}
	
}
