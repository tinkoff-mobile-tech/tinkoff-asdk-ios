//
//  IPayButtonViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

protocol IPayButtonViewPresenterAssembly {
    func build(
        presentationState: PayButtonViewPresentationState,
        output: IPayButtonViewPresenterOutput?
    ) -> IPayButtonViewOutput
}

extension IPayButtonViewPresenterAssembly {
    func build(presentationState: PayButtonViewPresentationState) -> IPayButtonViewOutput {
        build(presentationState: presentationState, output: nil)
    }

    func build(output: IPayButtonViewPresenterOutput?) -> IPayButtonViewOutput {
        build(presentationState: .pay, output: output)
    }

    func build() -> IPayButtonViewOutput {
        build(presentationState: .pay, output: nil)
    }
}
