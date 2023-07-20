//
//  AppBasedSdkUiProvider.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 20.07.2023.
//

import Foundation

/// Возвращает информацию для 3DS App Based SDK транзакции
public protocol IAppBasedSdkUiProvider {
    /// Тип интерфейса Native/HTML/Both через который пойдет транзакция
    func sdkInterface() -> TdsSdkInterface
    /// Тип ui-ая для проверки
    func sdkUiTypes() -> [TdsSdkUiType]
}

public struct AppBasedSdkUiProvider: IAppBasedSdkUiProvider {
    let prefferedInterface: TdsSdkInterface
    let prefferedUiTypes: [TdsSdkUiType]

    public init(prefferedInterface: TdsSdkInterface, prefferedUiTypes: [TdsSdkUiType]) {
        self.prefferedInterface = prefferedInterface
        self.prefferedUiTypes = prefferedUiTypes
    }

    public func sdkInterface() -> TdsSdkInterface {
        prefferedInterface
    }

    public func sdkUiTypes() -> [TdsSdkUiType] {
        prefferedUiTypes
    }
}
