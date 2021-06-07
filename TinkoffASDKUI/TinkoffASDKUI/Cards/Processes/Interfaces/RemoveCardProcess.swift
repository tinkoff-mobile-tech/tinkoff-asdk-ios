//
//
//  RemoveCardProcess.swift
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

protocol RemoveCardProcessDelegate: AnyObject {
    func removeCardProcessDidFinish(
        _ process: RemoveCardProcess,
        cardId: String,
        payload: RemoveCardPayload
    )
    func removeCardProccessDidFailed(
        _ process: RemoveCardProcess,
        cardId: String,
        error: Error
    )
}

protocol RemoveCardProcess: Cancellable {
    func start()
}
