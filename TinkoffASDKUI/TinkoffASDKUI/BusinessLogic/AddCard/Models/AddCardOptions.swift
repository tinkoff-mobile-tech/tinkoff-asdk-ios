//
//  AddCardOptions.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 07.08.2023.
//

import Foundation
import TinkoffASDKCore

/// Параметры для флоу привязки карты
public struct AddCardOptions {

    /// DATA - дополнительные поля для отправки на запрос `/AttachCard`
    ///
    /// `JSON` объект, содержащий дополнительные параметры в виде `[Key: Value]`
    ///
    /// `Key: String` – 20 знаков,
    /// `Value: DataValue` – 100 знаков.
    /// - Warning: Максимальное количество пар параметров не может превышать 20.
    /// Часть может быть зарезервирована `TinkoffAcquiringSDK`
    public let attachCardData: AdditionalData?

    public init(attachCardData: AdditionalData?) {
        self.attachCardData = attachCardData
    }
}

public extension AddCardOptions {

    static let empty = AddCardOptions(attachCardData: nil)
}
