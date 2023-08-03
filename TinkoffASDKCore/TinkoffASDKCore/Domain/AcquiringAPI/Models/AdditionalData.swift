//
//  AdditionalData.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 03.08.2023.
//

import Foundation

/// Дополнительные поля для параметра `DATA`
///
/// Используется в запросах:
/// Платежа `/Init` `/FinishAuthorize`
/// Привязки карты `/AttachCard`
///
/// `JSON` объект, содержащий дополнительные параметры в виде `[Key: Value]`
///
/// `Key: String` – 20 знаков,
/// `Value: String || Encodable` – 100 знаков.
/// - Warning: Максимальное количество пар параметров не может превышать 20.
/// Часть может быть зарезервирована `TinkoffAcquiringSDK`
///
public struct AdditionalData: Equatable, Encodable {

    public private(set) var data: [String: Encodable]

    public init(data: [String: Encodable]) {
        self.data = data
    }

    /// Добавляет новые значение в текущий data
    public mutating func merging(_ second: [String: Encodable]?) {
        guard let second = second else { return }
        second.forEach { item in
            data.updateValue(item.value, forKey: item.key)
        }
    }

    /// Создает пустой объект
    public static func empty() -> Self {
        AdditionalData(data: [:])
    }

    // MARK: - Encodable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        for (key, value) in data {
            guard let key = DynamicCodingKey(stringValue: key) else { return }
            try container.encode(value, forKey: key)
        }
    }

    // MARK: - Equatable

    public static func == (lhs: Self, rhs: Self) -> Bool {
        let lhsSortedKeys: [String] = lhs.data.keys.sorted()
        let rhsSortedKeys: [String] = rhs.data.keys.sorted()
        if lhsSortedKeys != rhsSortedKeys {
            return false
        } else {
            for key in lhsSortedKeys {
                let value1 = lhs.data[key]
                let value2 = rhs.data[key]
                return compareValues(value1, value2)
            }

            // when [:]
            return true
        }
    }

    private static func compareValues<T, U>(_ value1: T, _ value2: U) -> Bool {
        guard type(of: value1 as Any) == type(of: value2 as Any) else { return false }
        let mirrorValue1 = Mirror(reflecting: value1).description
        let mirrorValue2 = Mirror(reflecting: value2).description
        return mirrorValue1 == mirrorValue2
    }
}
