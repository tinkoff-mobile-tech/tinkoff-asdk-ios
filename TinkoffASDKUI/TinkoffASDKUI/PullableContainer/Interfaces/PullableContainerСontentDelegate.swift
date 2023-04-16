//
//  PullableContainerСontentDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 10.04.2023.
//

import Foundation

protocol PullableContainerСontentDelegate: AnyObject {
    func updateHeight(alongsideAnimation: VoidBlock?, completion: VoidBlock?)
}

extension PullableContainerСontentDelegate {
    func updateHeight(alongsideAnimation: @escaping VoidBlock) {
        updateHeight(alongsideAnimation: alongsideAnimation, completion: nil)
    }

    func updateHeight(completion: @escaping VoidBlock) {
        updateHeight(alongsideAnimation: nil, completion: completion)
    }

    func updateHeight() {
        updateHeight(alongsideAnimation: nil, completion: nil)
    }
}
