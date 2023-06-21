//
//  EmailViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

final class EmailViewPresenterAssembly: IEmailViewPresenterAssembly {
    // MARK: IEmailViewPresenterAssembly

    func build(customerEmail: String, output: IEmailViewPresenterOutput) -> IEmailViewOutput {
        EmailViewPresenter(customerEmail: customerEmail, output: output)
    }
}
