//
//  Data3DSVersion2WebFlowData.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 08.11.2022.
//

import Foundation

public struct Data3DSVersion2WebFlowData: Encodable {

    // Идентификатор выполнения 3DS Method
    // 'Y' - выполнение метода успешно завершено
    // 'N' - выполнение метода завершено неуспешно или метод не выполнялся
    let threeDSCompInd: String

    // Язык браузера по формату IETF BCP47
    // Рекомендация по получению значения в браузере (из глобального объекта navigator): navigator.language
    let language: String

    // Time-zone пользователя
    // Пример: UTC +5 hours: -300
    // Рекомендация по получению значения в браузере: вызов метода getTimezoneOffset()
    let timezone: String

    // Высота экрана в пикселях
    let screenHeight: String

    // Ширина экрана в пикселях
    let screenWidth: String

    // URL который будет использоваться для получения
    // результата(CRES)
    // завершения
    // Flow(аутентификаци дополнительным переходом на страницу ACS)
    let cresCallbackUrl: String

    enum CodingKeys: String, CodingKey {
        case threeDSCompInd
        case language
        case timezone
        case screenHeight = "screen_height"
        case screenWidth = "screen_width"
        case cresCallbackUrl
    }
}
