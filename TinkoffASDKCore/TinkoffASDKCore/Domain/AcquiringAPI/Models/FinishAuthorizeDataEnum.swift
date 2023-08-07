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

extension FinishAuthorizeDataEnum: Encodable {

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .threeDsBrowser(wrappedData):
            let finishAuthorizeData3Ds = wrappedData.data
            try finishAuthorizeData3Ds.encode(to: encoder)
            try wrappedData.additionalData?.encode(to: encoder)

        case let .threeDsSdk(wrappedData):
            let finishAuthorizeData3DsSDK = wrappedData.data
            try finishAuthorizeData3DsSDK.encode(to: encoder)
            try wrappedData.additionalData?.encode(to: encoder)

        case let .dictionary(data):
            try data.encode(to: encoder)
        }
    }
}
