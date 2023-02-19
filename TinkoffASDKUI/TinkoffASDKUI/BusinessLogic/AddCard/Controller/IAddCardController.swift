//
//  IAddCardController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.02.2023.
//

import Foundation
import TinkoffASDKCore

typealias AddCardStateCompletion = (AddCardStateResult) -> Void

protocol IAddCardController: AnyObject {
    var webFlowDelegate: ThreeDSWebFlowDelegate? { get set }

    func addCard(options: AddCardOptions, completion: @escaping AddCardStateCompletion)
}
