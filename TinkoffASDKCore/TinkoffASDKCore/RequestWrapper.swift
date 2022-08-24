//
//
//  RequestWrapper.swift
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


import Foundation

final class RequestWrapper: Cancellable {
    typealias Closure = (Cancellable) -> Void

    init(action: @escaping (@escaping Closure) -> Void) {
        self.action = action
    }

    private weak var cancallable: Cancellable?
    
    func execute() {
        action() { [weak self] cancallable in
            self?.cancallable = cancallable
        }
    }

    private let action: (@escaping Closure) -> Void
    
    func cancel() {
        cancallable?.cancel()
    }
}
