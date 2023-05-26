//
//  CardFieldPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 22.05.2023.
//

final class CardFieldPresenterAssembly: ICardFieldPresenterAssembly {
    // MARK: Dependencies

    private let validator: ICardRequisitesValidator
    private let paymentSystemResolver: IPaymentSystemResolver
    private let bankResolver: IBankResolver
    private let inputMaskResolver: ICardRequisitesMasksResolver

    // MARK: Initialization

    init(
        validator: ICardRequisitesValidator,
        paymentSystemResolver: IPaymentSystemResolver,
        bankResolver: IBankResolver,
        inputMaskResolver: ICardRequisitesMasksResolver
    ) {
        self.validator = validator
        self.paymentSystemResolver = paymentSystemResolver
        self.bankResolver = bankResolver
        self.inputMaskResolver = inputMaskResolver
    }

    // MARK: ICardFieldPresenterAssembly

    func build(output: ICardFieldOutput?, isScanButtonNeeded: Bool) -> ICardFieldViewOutput {
        CardFieldPresenter(
            output: output,
            isScanButtonNeeded: isScanButtonNeeded,
            validator: validator,
            paymentSystemResolver: paymentSystemResolver,
            bankResolver: bankResolver,
            inputMaskResolver: inputMaskResolver
        )
    }
}
