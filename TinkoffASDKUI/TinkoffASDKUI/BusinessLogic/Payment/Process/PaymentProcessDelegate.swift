//
//  PaymentProcessDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

protocol PaymentProcessDelegate: AnyObject {

    /// Оплата завершилась успехом
    func paymentDidFinish(
        _ paymentProcess: IPaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    )

    /// Оплата завершилась ошибкой
    func paymentDidFailed(
        _ paymentProcess: IPaymentProcess,
        with error: Error,
        cardId: String?,
        rebillId: String?
    )

    // MARK: - Three DS Verification v1.0

    /*

     Разделение на шаги:
     1 шаг - сбор начальной информации об устройстве с которого проводим транзакцию
     2 шаг - финальная проверка 3дс транзакции (если потребуется). Прохождение challeng-а (например ввод отп кода)

     */

    /// 2 шаг
    /// Требуется проверка 3дс browser (3ds v1.0)
    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmation data: Confirmation3DSData,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    )

    // MARK: - Three DS Verification v2.0

    /// 1 шаг
    /// Требуется пройти 3дс challenge browser flow (3ds v2.0)
    func payment(
        _ paymentProcess: IPaymentProcess,
        needToCollect3DSData checking3DSURLData: Checking3DSURLData,
        completion: @escaping (ThreeDsDataBrowser) -> Void
    )

    /// 2 шаг
    /// Проверка через 3дс транзакцию challenge browser flow (3ds v2.0)
    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmationACS data: Confirmation3DSDataACS,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    )

    /// 1 шаг
    /// Начать 3ds SDK проверку app based flow (3ds v2.0)
    func startAppBasedFlow(
        check3dsPayload: Check3DSVersionPayload,
        completion: @escaping (Result<ThreeDsDataSDK, Error>) -> Void
    )

    /// 2 шаг
    /// Challenge 3ds SDK app based flow (3ds v2.0)
    func payment(
        _ paymentProcess: IPaymentProcess,
        need3DSConfirmationAppBased data: Confirmation3DS2AppBasedData,
        version: String,
        confirmationCancelled: @escaping () -> Void,
        completion: @escaping (Result<GetPaymentStatePayload, Error>) -> Void
    )
}
