//
//  EmailValidator.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 27.07.2023.
//

import Foundation

public protocol IEmailValidator {
    /// Валидация поля email
    func isValid(_ email: String?) -> Bool
}

public final class EmailValidator: IEmailValidator {

    public init() {}

    /// Валидация поля email
    public func isValid(_ email: String?) -> Bool {
        Self.validate(email)
    }

    static func validate(_ email: String?) -> Bool {
        guard let email = email else { return false }
        let emailRegEx = ".+\\@.+\\..+"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
