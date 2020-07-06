//
//  PaymentStatusServiceProvider.swift
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

public final class PaymentStatusServiceProvider: FetchServiceProtocol {
	
	public typealias ObjectType = PaymentStatusResponse
	/// Текущее состояние сервиса проверки
	public var fetchStatus: FetchStatus<PaymentStatusResponse> = .unknow
	var queryStatus: Cancellable?
	/// Слушатель состояния сервиса проверки
	public var onStatusUpdated: ((FetchStatus<PaymentStatusResponse>) -> Void)?
	/// Платеж состояние которого проверяем
	private(set) var paymentId: Int64 = 0
	/// Частота обновления, не менее 10 сек
	public var updateTimeInterval: TimeInterval = 5 {
		didSet {
			if updateTimeInterval < 5 {
				updateTimeInterval = 5
			}
		}
	}
	
	private weak var sdk: AcquiringSdk?
	
	public init(sdk: AcquiringSdk?, paymentId: Int64, updateTimeInterval: TimeInterval = 5) {
		self.sdk = sdk
		self.paymentId = paymentId
		self.updateTimeInterval = updateTimeInterval
	}
	
	/// Запустить проверку статуса платежа
	/// - Parameter completionStatus: `[PaymentStatus]`статусы для которых проверка завршается, конечные статусы
	///   по умолчанию выставлены [.cancelled, .authorized, .checked3ds, .refunded, .reversed, .rejected]
	public func fetchStatus(completionStatus: [PaymentStatus] = [.cancelled, .authorized, .checked3ds, .refunded, .reversed, .rejected]) {
		if case .loading = fetchStatus { return }
		
		fetch(startHandler: nil) { [weak self] (payment, errors) in
			if let paymentResponse = payment, completionStatus.contains(paymentResponse.status) {
				return
			}
			
			if let timeInterval = self?.updateTimeInterval {
				DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) { [weak self] in
					self?.fetchStatus(completionStatus: completionStatus)
				}
			}
		}
		
	}//fetchStatus
	
	// MARK: FetchDataSourceProtocol
	
	public func fetch(startHandler: (() -> Void)?, completeHandler: @escaping (PaymentStatusResponse?, Error?) -> Void) {
		fetchStatus = .loading
		startHandler?()
		
		queryStatus = sdk?.paymentOperationStatus(data: PaymentInfoData.init(paymentId: paymentId), completionHandler: { [weak self] (response) in
			var status: FetchStatus<PaymentStatusResponse> = .loading
			switch response {
				case .failure(let error):
					status = FetchStatus.error(error)
					completeHandler(nil, error)
				
				case .success(let paymentResponse):
					status = FetchStatus.object(paymentResponse)
					completeHandler(paymentResponse, nil)
				
			}
			
			self?.fetchStatus = status
			
			DispatchQueue.main.async { [weak self] in
				self?.onStatusUpdated?(status)
			}
			
		})
	}
	
}
