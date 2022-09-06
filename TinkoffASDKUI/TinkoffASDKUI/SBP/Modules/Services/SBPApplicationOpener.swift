//
//
//  SBPApplicationOpener.swift
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
import UIKit

public protocol SBPApplicationOpener {
    func openSBPUrl(_ url: URL, in bankApplication: SBPBank, completion: ((Bool) -> Void)?) throws
}

public final class DefaultSBPApplicationOpener: SBPApplicationOpener {
    enum Error: Swift.Error {
        case invalidSBPUrl
    }
    
    private let application: UIApplication
    
    public init(application: UIApplication) {
        self.application = application
    }
    
    public func openSBPUrl(_ url: URL, in bankApplication: SBPBank, completion: ((Bool) -> Void)?) throws {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { throw Error.invalidSBPUrl }
        components.scheme = bankApplication.schema
        guard let resultUrl = components.url else { throw Error.invalidSBPUrl }
        application.open(resultUrl, options: [:], completionHandler: completion)
    }
}
