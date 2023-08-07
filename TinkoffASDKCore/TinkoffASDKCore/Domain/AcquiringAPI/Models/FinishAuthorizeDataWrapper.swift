//
//  FinishAuthorizeDataWrapper.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 02.08.2023.
//

import Foundation

public struct FinishAuthorizeDataWrapper<T> where T: Encodable {
    public let data: T
    public let additionalData: AdditionalData?

    public init(data: T, additionalData: AdditionalData?) {
        self.data = data
        self.additionalData = additionalData
    }
}
