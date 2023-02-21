//
//  ISBPBanksAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

protocol ISBPBanksAssembly {

    /// Формирует модуль, когда уже есть пре загруженная платежная информация
    /// - Parameter paymentSheetOutput: делегат ответов от платежной шторки
    /// - Returns: Возвращает сформированный модуль
    func buildPreparedModule(paymentSheetOutput: ISBPPaymentSheetPresenterOutput?) -> SBPBanksModule

    /// Формирует модуль, когда нет загруженной платежной информации и требуется ее загрузить внутри модуля
    /// - Parameter paymentConfiguration: необходимые данные для загрузки платежной информации
    /// - Parameter paymentSheetOutput: делегат ответов от платежной шторки
    /// - Returns: Возвращает сформированный модуль
    func buildInitialModule(
        paymentFlow: PaymentFlow,
        paymentSheetOutput: ISBPPaymentSheetPresenterOutput?
    ) -> SBPBanksModule
}
