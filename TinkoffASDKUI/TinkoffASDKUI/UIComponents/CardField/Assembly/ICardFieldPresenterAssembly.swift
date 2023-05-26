//
//  ICardFieldPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.05.2023.
//

protocol ICardFieldPresenterAssembly {
    func build(output: ICardFieldOutput?, isScanButtonNeeded: Bool) -> ICardFieldViewOutput
}

extension ICardFieldPresenterAssembly {
    func build(isScanButtonNeeded: Bool) -> ICardFieldViewOutput {
        build(output: nil, isScanButtonNeeded: isScanButtonNeeded)
    }
}
