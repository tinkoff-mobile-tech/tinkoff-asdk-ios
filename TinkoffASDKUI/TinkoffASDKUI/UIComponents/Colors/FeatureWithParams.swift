//
//  FeatureWithParams.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import Foundation

enum FeatureWithParams<T> {
    case on(params: T)
    case off
}

extension FeatureWithParams {
    var isOn: Bool {
        switch self {
        case .on: return true
        case .off: return false
        }
    }

    var params: T? {
        switch self {
        case let .on(value): return value
        case .off: return nil
        }
    }
}

extension FeatureWithParams: Equatable where T: Equatable {}
