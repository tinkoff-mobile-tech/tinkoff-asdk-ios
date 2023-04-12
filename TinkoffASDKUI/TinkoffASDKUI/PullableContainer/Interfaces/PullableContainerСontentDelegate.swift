//
//  PullableContainerСontentDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 10.04.2023.
//

import Foundation

protocol PullableContainerСontentDelegate: AnyObject {
    func updateHeight(animated: Bool, completion: VoidBlock?)
}

extension PullableContainerСontentDelegate {
    func updateHeight(animated: Bool) {
        updateHeight(animated: animated, completion: nil)
    }
}
