//
//  Result+Utils.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

extension Result {
    func tryMap<T>(_ transform: (Success) throws -> T) -> Result<T, Error> {
        switch self {
        case let .success(success):
            do {
                return .success(try transform(success))
            } catch {
                return .failure(error)
            }
        case let .failure(failure):
            return .failure(failure)
        }
    }
}
