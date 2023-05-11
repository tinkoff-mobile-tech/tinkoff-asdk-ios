//
//  IRecurrentPaymentFailiureDelegate.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 07.03.2023.
//

public typealias PaymentId = String

/// Делегат, обрабатывающий ошибку списания средств при вызове `v2/Charge`
///
/// Используется только при оплате на основе уже существующего `paymentId (PaymentFlow.finish)`
public protocol IRecurrentPaymentFailiureDelegate: AnyObject {
    /// В случае вызова этого метода делегата, необходимо совершить повторный запрос v2/Init, для получения обновленного paymentId
    /// для этого необходимо в запросе к полю DATA добавить additionalData (в PaymentOptions поле называется paymentFormData)
    /// - Parameters:
    ///   - additionalData: содержаться два доп. поля failMapiSessionId c failedPaymentId и recurringType
    ///   - completion: после успешного выполнения запроса, необходимо передать в completion новый paymentId
    func recurrentPaymentNeedRepeatInit(additionalData: [String: String], completion: @escaping (Result<PaymentId, Error>) -> Void)
}
