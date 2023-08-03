//
//  ThreeDsDataSDK.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 01.08.2023.
//

import Foundation

/// Набор параметров для 3дс транзакции через App Based Flow
public struct ThreeDsDataSDK: Encodable {

    /// Уникальный идентификатор приложения 3DS Requestor, который
    /// формируется 3DS SDK при каждой установке или обновлении приложения
    public let sdkAppID: String

    /// Компонент public key пары ephemeral key, сгенерированный 3DS SDK.
    /// JWE объект, полученный от 3DS SDK, должен быть дополнительно закодирован в base64 строку
    public let sdkEphemPubKey: String

    /// Поставщик и версия 3DS SDK
    /// Identifies the vendor and version of the 3DS SDK that is utilised for a specific transaction.
    /// The value is assigned by EMVCo
    public let sdkReferenceNumber: String

    /// Уникальный идентификатор транзакции, назначенный 3DS SDK для идентификации одной транзакции
    public let sdkTransID: String

    /// Максимальное количество времени (в минутах)
    ///
    /// Values accepted: Greater than or = 05
    public let sdkMaxTimeout: String

    /// Данные, собранные SDK.
    /// JWE объект, полученный от 3DS SDK.
    /// Должен быть дополнительно закодирован в base64 строку
    public let sdkEncData: String

    /// Список поддерживаемых интерфейсов SDK.
    /// Поддерживаемые значения:
    ///
    /// Values accepted:
    /// - 01 = Native
    /// - 02 = HTML
    /// - 03 = Both
    public let sdkInterface: TdsSdkInterface

    /// Список поддерживаемых типов UI.
    /// Lists all UI types that the device supports for displaying
    /// specific challenge user interfaces within the 3DS SDK.
    ///
    /// Valid values for each Interface:
    /// - Native UI = 01–04
    /// - HTML UI = 01–05
    ///
    /// Values accepted:
    /// - 01 = Text
    /// - 02 = Single Select
    /// - 03 = Multi Select
    /// - 04 = OOB
    /// - 05 = HTML Other (valid only for HTML UI)
    public let sdkUiType: String

    public init(
        sdkAppID: String,
        sdkEphemPubKey: String,
        sdkReferenceNumber: String,
        sdkTransID: String,
        sdkMaxTimeout: String,
        sdkEncData: String,
        sdkInterface: TdsSdkInterface,
        sdkUiType: String
    ) {
        self.sdkAppID = sdkAppID
        self.sdkEphemPubKey = sdkEphemPubKey
        self.sdkReferenceNumber = sdkReferenceNumber
        self.sdkTransID = sdkTransID
        self.sdkMaxTimeout = sdkMaxTimeout
        self.sdkEncData = sdkEncData
        self.sdkInterface = sdkInterface
        self.sdkUiType = sdkUiType
    }
}
