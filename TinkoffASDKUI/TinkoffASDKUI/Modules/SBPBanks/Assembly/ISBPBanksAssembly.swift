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

    /// Формирует модуль, когда нет загруженной платежной информации и требуется ее загрузить внутри модуля.
    /// Предназначен для внешнего использования, вместо paymentSheetOutput у него completion
    /// - Parameter paymentConfiguration: необходимые данные для загрузки платежной информации
    /// - Parameter completion: передает ответы от платежной шторки
    /// - Returns: Возвращает сформированный модуль
    func buildInitialModule(
        paymentFlow: PaymentFlow,
        completion: PaymentResultCompletion?
    ) -> SBPBanksModule

    /// Формирует модуль, когда нет загруженной платежной информации и требуется ее загрузить внутри модуля
    /// - Parameter paymentConfiguration: необходимые данные для загрузки платежной информации
    /// - Parameter output: необходим для передачи загруженных внутри модуля списка банков
    /// - Parameter paymentSheetOutput: делегат ответов от платежной шторки
    /// - Returns: Возвращает сформированный модуль
    func buildInitialModule(
        paymentFlow: PaymentFlow,
        output: ISBPBanksModuleOutput?,
        paymentSheetOutput: ISBPPaymentSheetPresenterOutput?
    ) -> SBPBanksModule
}
