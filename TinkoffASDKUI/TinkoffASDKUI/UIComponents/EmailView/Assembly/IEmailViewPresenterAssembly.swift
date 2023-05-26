//
//  IEmailViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

protocol IEmailViewPresenterAssembly {
    func build(customerEmail: String, output: IEmailViewPresenterOutput) -> IEmailViewOutput
}
