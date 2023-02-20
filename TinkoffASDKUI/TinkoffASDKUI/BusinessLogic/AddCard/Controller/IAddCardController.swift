//
//  IAddCardController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.02.2023.
//

import Foundation
import TinkoffASDKCore

public protocol IAddCardController: AnyObject {
    var webFlowDelegate: ThreeDSWebFlowDelegate? { get set }

    func addCard(options: AddCardOptions, completion: @escaping (AddCardStateResult) -> Void)
}
