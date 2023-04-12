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
        ^((220[0-4])|\
        356(299|504|514|546)|505827|561468|623446|629129|629244|676347|676454|\
        676531|671182|629157|676884|676907|677319|677384|86000[2-9]|86001[1-4]|\
        860020|86003[0-1]|86003[3-4]|860038|860043|860048|860049|86005[0-1]|\
        860053|86005[5-9]|860060|860061|90511[4-9]|905121|905122|905127|905129|\
        905132|905134|905135|911238|911288|\
        911289|94170[1-3]|94170[8-9]|94171[0-4]|941717|941718|94172[0-9]|94173[0-9]|\
        941740|94174[3-9]|94175[0-5]|94175[7-8]|94176[0-9]|94177[0-6]|941798|941704|\
        941707|976200|97625[1-4]|977700|99900[3-5]|99900[7-9]|999010).*$
        """

        var regex: NSRegularExpression? {
            try? NSRegularExpression(pattern: rawValue)
        }
    }
}
