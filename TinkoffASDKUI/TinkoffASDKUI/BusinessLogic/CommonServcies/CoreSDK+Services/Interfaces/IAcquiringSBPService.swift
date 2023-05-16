//
//  IAcquiringSBPService.swift
//  TinkoffASDKCore
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

import TinkoffASDKCore

protocol IAcquiringSBPService {
    // MARK: Load SBP Banks

    /// Загрузить список банков, через приложения которых можно совершить оплату СБП
    ///
    /// - Parameters:
    ///   - completion: результат запроса. `GetSBPBanksPayload` в случае успешного запроса и  `Error` - ошибка.
    @discardableResult
    func loadSBPBanks(completion: @escaping (Result<GetSBPBanksPayload, Error>) -> Void) -> Cancellable

    // MARK: Get QR

    /// Сгенерировать QR для оплаты
    ///
    /// - Parameters:
    ///   - data: `GetQRData` информация о заказе на оплату
    ///   - completion: результат операции `GetQRPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    func getQR(
        data: GetQRData,
        completion: @escaping (_ result: Result<GetQRPayload, Error>) -> Void
    ) -> Cancellable
    
    // MARK: Get Static QR

    /// Выставить счет / принять оплату, сгенерировать QR для принятия платежей
    ///
    /// - Parameters:
    ///   - data: `GetQRDataType` тип возвращаемых данных для генерации QR-кода
    ///   - completion: результат операции `GetStaticQRPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    func getStaticQR(
        data: GetQRDataType,
        completion: @escaping (_ result: Result<GetStaticQRPayload, Error>) -> Void
    ) -> Cancellable
}
