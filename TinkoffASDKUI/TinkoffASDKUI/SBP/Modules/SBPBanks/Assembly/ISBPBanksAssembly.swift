//
//  ISBPBanksAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

protocol ISBPBanksAssembly {

    /// Формирует модуль, когда уже есть пре загруженная платежная информация
    /// - Returns: Возвращает сформированный модуль
    func buildPreparedModule() -> SBPBanksModule

    /// Формирует модуль, когда нет загруженной платежной информации и требуется ее загрузить внутри модуля
    /// - Parameter paymentConfiguration: необходимые данные для загрузки платежной информации
    /// - Returns: Возвращает сформированный модуль
    func buildInitialModule(paymentConfiguration: AcquiringPaymentStageConfiguration) -> SBPBanksModule
}
