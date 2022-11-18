//
//  PaymentSystem.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 16.11.2022.
//

import Foundation

enum PaymentSystem: CaseIterable {
    case visa
    case masterCard
    case maestro
    case mir
    case unionPay

    var regexPattern: Pattern {
        switch self {
        case .visa:
            return Pattern.visa
        case .masterCard:
            return Pattern.masterCard
        case .maestro:
            return Pattern.maestro
        case .mir:
            return Pattern.mir
        case .unionPay:
            return Pattern.unionPay
        }
    }

    var icon: DynamicIconCardView.Icon.PaymentSystem {
        switch self {
        case .visa:
            return .visa
        case .masterCard:
            return .masterCard
        case .maestro:
            return .maestro
        case .mir:
            return .mir
        case .unionPay:
            return .uninonPay
        }
    }
}

extension PaymentSystem {

    // MARK: Payment System's Patterns

    enum Pattern: String, CaseIterable {
        case visa = "^(4[0-9]*)$"
        case masterCard = "^(5(?!05827|61468)[0-9]*)$"
        case maestro = "^(6(?!2|76347|76454|76531|71182|76884|76907|77319|77384)[0-9]*)$"
        case unionPay = "^((81[0-6]|817[01]|62(?!3446|9129|9157|9244))[0-9]*)$"
        case mir = """
        ^((220[0-4]|356|505827|561468|623446|629129|629157|629244|676347\
        |676454|676531|671182|676884|676907|677319|677384|8600|9051|9112\
        (?!00|50|39|99)|9417(?!00|99)|9762|9777|9990(?!01))[0-9]*)$
        """

        var regex: NSRegularExpression? {
            try? NSRegularExpression(pattern: rawValue)
        }
    }
}
