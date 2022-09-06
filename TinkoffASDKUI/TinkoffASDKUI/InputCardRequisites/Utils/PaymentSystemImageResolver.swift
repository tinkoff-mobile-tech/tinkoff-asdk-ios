//
//
//  PaymentSystemImageResolver.swift
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
import UIKit

protocol IPaymentSystemImageResolver {
    func resolve(by inputPAN: String?) -> UIImage?
}

final class PaymentSystemImageResolver: IPaymentSystemImageResolver {
    private let paymentSystemResolver: IPaymentSystemResolver

    init(paymentSystemResolver: IPaymentSystemResolver = PaymentSystemResolver()) {
        self.paymentSystemResolver = paymentSystemResolver
    }

    func resolve(by inputPAN: String?) -> UIImage? {
        switch paymentSystemResolver.resolve(by: inputPAN) {
        case .resolved(.visa):
            return .visa
        case .resolved(.masterCard):
            return .masterCard
        case .resolved(.maestro):
            return .maestro
        case .resolved(.mir):
            return .mir
        case .ambiguous, .unrecognized:
            return nil
        }
    }
}

// MARK: - UIImage + Payment Systems

private extension UIImage {
    static let visa: UIImage = Asset.CardRequisites.visaLogo.image
    static let masterCard: UIImage = Asset.CardRequisites.mcLogo.image
    static let maestro: UIImage = Asset.CardRequisites.maestroLogo.image
    static let mir: UIImage = Asset.CardRequisites.mirLogo.image
}
