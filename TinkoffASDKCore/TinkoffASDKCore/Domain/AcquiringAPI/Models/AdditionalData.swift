//
//  AdditionalData.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 03.08.2023.
//

import Foundation

/// Тип значения DATA
public typealias DataValue = Equatable & Encodable

/// Дополнительные поля для параметра `DATA`
///
/// Используется в запросах:
/// Платежа `/Init` `/FinishAuthorize`
/// Привязки карты `/AttachCard`
///
/// `JSON` объект, содержащий дополнительные параметры в виде `[Key: Value]`
///
/// `Key: String` – 20 знаков,
/// `Value: DataValue` – 100 знаков.
/// - Warning: Максимальное количество пар параметров не может превышать 20.
/// Часть может быть зарезервирована `TinkoffAcquiringSDK`
///
public struct AdditionalData {

    public private(set) var data: [String: any DataValue]

    public init(data: [String: any DataValue]) {
        self.data = data
    }

    /// Добавляет новые значение в текущий data
    public mutating func merging(_ second: [String: any DataValue]?) {
        guard let second = second else { return }
        second.forEach { item in
            data.updateValue(item.value, forKey: item.key)
        }
    }

    public mutating func merging(_ second: AdditionalData?) {
        merging(second?.data)
    }

    /// Создает пустой объект
    public static func empty() -> Self {
        AdditionalData(data: [:])
    }
}

extension AdditionalData: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        for (key, value) in data {
            guard let key = DynamicCodingKey(stringValue: key) else { return }
            try container.encode(value, forKey: key)
        }
    }
}

extension AdditionalData: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        let lhsSortedKeys: [String] = lhs.data.keys.sorted()
        let rhsSortedKeys: [String] = rhs.data.keys.sorted()
        if lhsSortedKeys != rhsSortedKeys {
            return false
        } else {
            let result = lhsSortedKeys.map { key in
                guard let value1 = lhs.data[key], let value2 = rhs.data[key] else { return false }
                return value1.isEqual(value2)
            }.allSatisfy { $0 == true }

            return result
        }
    }
}

private extension Equatable {

    // Little hack to compare any Equatable
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else { return other.isExactlyEqual(self) }
        return self == other
    }

    // For Subtypes
    private func isExactlyEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}
