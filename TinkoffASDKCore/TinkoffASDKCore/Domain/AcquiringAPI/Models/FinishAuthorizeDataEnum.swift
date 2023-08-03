//
//  FinishAuthorizeDataEnum.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 01.08.2023.
//

import Foundation

// Максимальная длина для каждого передаваемого параметра:
//
// Ключ - 20 знаков;
// Значение - 100 знаков. Максимальное количество пар ключ:значение не может превышать 20.
public enum FinishAuthorizeDataEnum {
    /// 3DS Data Browser Flow + Fields
    case threeDsBrowser(FinishAuthorizeDataWrapper<ThreeDsDataBrowser>)
    /// 3DS Data App Based Flow + Fields
    case threeDsSdk(FinishAuthorizeDataWrapper<ThreeDsDataSDK>)
    /// Just Fields
    case dictionary(AdditionalData)
}

public extension FinishAuthorizeDataEnum {

    /// Валидация объекта по правилам МАПИ
    func validate() -> Result<Void, Error> {
        var jsonObject: JSONObject

        do {
            jsonObject = try encode2JSONObject()
        } catch {
            return .failure(error)
        }

        // Максимальное количество пар ключ:значение не может превышать 20
        if jsonObject.keys.count > 20 {
            return .failure(ASDKCoreError.invalidFinishAuthorizeData)
        }

        var keyCountHitLimit = false
        var valueCountHitLimit = false

        for (key, value) in jsonObject {
            // Ключ не более 20 знаков
            if key.count > 20 {
                keyCountHitLimit = true
            }
            // Значение не более 100 знаков
            if (value as? String)?.count ?? .zero > 100 {
                valueCountHitLimit = true
            }
        }

        if keyCountHitLimit || valueCountHitLimit {
            return .failure(ASDKCoreError.invalidFinishAuthorizeData)
        } else {
            return .success(())
        }
    }
}

extension FinishAuthorizeDataEnum: Encodable {

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .threeDsBrowser(wrappedData):
            let finishAuthorizeData3Ds = wrappedData.data
            try finishAuthorizeData3Ds.encode(to: encoder)
            if let additionalData = wrappedData.additionalData {
                try additionalData.encode(to: encoder)
            }

        case let .threeDsSdk(wrappedData):
            let finishAuthorizeData3DsSDK = wrappedData.data
            try finishAuthorizeData3DsSDK.encode(to: encoder)
            if let additionalData = wrappedData.additionalData {
                try additionalData.encode(to: encoder)
            }

        case let .dictionary(data):
            try data.encode(to: encoder)
        }
    }
}
