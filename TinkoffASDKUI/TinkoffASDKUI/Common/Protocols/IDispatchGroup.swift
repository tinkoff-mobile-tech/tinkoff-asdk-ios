//
//  IDispatchGroup.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.04.2023.
//

import Foundation

protocol IDispatchGroup {
    func notify(
        qos: DispatchQoS,
        flags: DispatchWorkItemFlags,
        queue: DispatchQueue,
        execute work: @escaping @convention(block) () -> Void
    )

    func enter()
    func leave()
}

extension IDispatchGroup {
    func notify(queue: DispatchQueue, execute work: @escaping @convention(block) () -> Void) {
        notify(qos: .unspecified, flags: [], queue: queue, execute: work)
    }
}

extension DispatchGroup: IDispatchGroup {}
