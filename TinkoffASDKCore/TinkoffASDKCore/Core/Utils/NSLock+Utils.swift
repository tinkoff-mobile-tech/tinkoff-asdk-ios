//
//  NSLock+Utils.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 28.09.2022.
//

import Foundation

extension NSLock {
    func sync<T>(_ block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}
