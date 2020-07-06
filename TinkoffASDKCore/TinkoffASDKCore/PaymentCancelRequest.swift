//
//  PaymentCancelRequest.swift
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

class PaymentCancelRequest: RequestOperation, AcquiringRequestTokenParams {
	
	// MARK: RequestOperation
	
	var name: String = "Cancel"
	
	var parameters: JSONObject?
	
	// MARK: AcquiringRequestTokenParams
	
	///
	/// отмечаем параметры которые участвуют в вычислении `token`
	var tokenParamsKey: Set<String> = [PaymentInfoData.CodingKeys.paymentId.rawValue]
	
	///
	/// - Parameter data: `FinishRequestData`
	init(data: PaymentInfoData) {
		if let json = try? data.encode2JSONObject() {
			self.parameters = json
		}
	}
	
}
