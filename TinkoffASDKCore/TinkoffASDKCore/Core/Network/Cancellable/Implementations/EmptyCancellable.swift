//
//  EmptyCancellable.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

public final class EmptyCancellable: Cancellable {
    public init() {}

    public func cancel() {}
}
