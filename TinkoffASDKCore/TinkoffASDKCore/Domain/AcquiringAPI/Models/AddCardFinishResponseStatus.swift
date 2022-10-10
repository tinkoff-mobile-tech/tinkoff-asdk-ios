//
//  AddCardFinishResponseStatus.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

public enum AddCardFinishResponseStatus {
    /// Требуется подтверждение 3DS v1.0
    case needConfirmation3DS(Confirmation3DSData)
    /// Требуется подтверждение 3DS v2.0
    case needConfirmation3DSACS(Confirmation3DSDataACS)
    /// Требуется подтвердить оплату и указать сумму из смс для `requestKey`
    case needConfirmationRandomAmount(String)
    /// Успешная оплата
    case done(AddCardStatusResponse)
    /// что-то пошло не так
    case unknown
}
