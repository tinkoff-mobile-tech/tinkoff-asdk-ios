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

    public init(prefferedInterface: TdsSdkInterface) {
        self.prefferedInterface = prefferedInterface
    }

    public func sdkInterface() -> TdsSdkInterface {
        prefferedInterface
    }

    public func sdkUiTypes() -> [TdsSdkUiType] {
        let allUiVariants = TdsSdkUiType.allCases
        switch sdkInterface() {
        case .native: return allUiVariants.filter { $0 != .html }
        case .html, .both: return allUiVariants
        }
    }
}
