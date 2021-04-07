//
//
//  AddCardProcess.swift
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


import TinkoffASDKCore

protocol AddCardProcessDelegate: AnyObject {
    func addCardProcessDidFinish(_ addCardProcess: AddCardProcess, state: GetAddCardStatePayload)
    func addCardProcessDidFailed(_ addCardProcess: AddCardProcess, error: Error)
    func addCardProcess(_ addCardProcess: AddCardProcess,
                        need3DSConfirmation data: Confirmation3DSData,
                        confirmationCancelled: @escaping () -> Void,
                        completion: @escaping (Result<AddCardStatusResponse, Error>) -> Void)
    func addCardProcess(_ addCardProcess: AddCardProcess,
                        need3DSConfirmationACS data: Confirmation3DSDataACS,
                        confirmationCancelled: @escaping () -> Void,
                        completion: @escaping (Result<AddCardStatusResponse, Error>) -> Void)
    func addCardProcess(_ addCardProcess: AddCardProcess,
                        needRandomAmountConfirmation requestKey: String,
                        confirmationCancelled: @escaping () -> Void,
                        completion: @escaping (Result<AddCardStatusResponse, Error>) -> Void)
}

protocol AddCardProcess {
    func addCard(cardData: CardData, checkType: PaymentCardCheckType)
}
