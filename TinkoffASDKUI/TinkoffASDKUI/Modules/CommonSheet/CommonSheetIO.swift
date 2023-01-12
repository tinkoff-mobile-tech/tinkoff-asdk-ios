//
//  CommonSheetIO.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import Foundation

protocol ICommonSheetViewInput: AnyObject {
    func update(state: CommonSheetState)
    func close()
}

protocol ICommonSheetViewOutput {
    func viewDidLoad()
    func primaryButtonTapped()
    func secondaryButtonTapped()
    func viewWasClosed()
}
