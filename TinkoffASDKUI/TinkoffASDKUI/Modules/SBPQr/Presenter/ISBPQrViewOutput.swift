//
//  ISBPQrViewOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import Foundation

protocol ISBPQrViewOutput {
    func viewDidLoad()
    func viewWasClosed()

    func numberOfRows() -> Int
    func cellType(at indexPath: IndexPath) -> SBPQrCellType

    func commonSheetViewDidTapPrimaryButton()
    func commonSheetViewDidTapSecondaryButton()
}
