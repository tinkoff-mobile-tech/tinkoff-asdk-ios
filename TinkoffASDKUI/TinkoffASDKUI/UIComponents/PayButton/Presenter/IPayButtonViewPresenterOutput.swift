//
//  IPayButtonViewPresenterOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

protocol IPayButtonViewPresenterOutput: AnyObject {
    func payButtonViewTapped(_ presenter: IPayButtonViewPresenterInput)
}
