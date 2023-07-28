//
//  EmailViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

import TinkoffASDKCore

final class EmailViewPresenterAssembly: IEmailViewPresenterAssembly {
    // MARK: IEmailViewPresenterAssembly

    func build(customerEmail: String, output: IEmailViewPresenterOutput) -> IEmailViewOutput {
        let emailValidator = EmailValidator()

        return EmailViewPresenter(
            customerEmail: customerEmail,
            output: output,
            emailValidator: emailValidator
        )
    }
}
