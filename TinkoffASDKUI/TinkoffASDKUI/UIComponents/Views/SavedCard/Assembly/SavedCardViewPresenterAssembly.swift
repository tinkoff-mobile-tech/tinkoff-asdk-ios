//
//  SavedCardViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

final class SavedCardViewPresenterAssembly: ISavedCardViewPresenterAssembly {
    // MARK: Dependencies

    private let validator: ICardRequisitesValidator
    private let paymentSystemResolver: IPaymentSystemResolver
    private let bankResolver: IBankResolver

    // MARK: Initialization

    init(
        validator: ICardRequisitesValidator,
        paymentSystemResolver: IPaymentSystemResolver,
        bankResolver: IBankResolver
    ) {
        self.validator = validator
        self.paymentSystemResolver = paymentSystemResolver
        self.bankResolver = bankResolver
    }

    // MARK: ISavedCardViewPresenterAssembly

    func build(output: ISavedCardViewPresenterOutput) -> ISavedCardViewOutput {
        SavedCardViewPresenter(
            validator: validator,
            paymentSystemResolver: paymentSystemResolver,
            bankResolver: bankResolver,
            output: output
        )
    }
}
