//
//  ISBPBankCellPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 29.12.2022.
//

protocol ISBPBankCellPresenterAssembly {
    func build(cellType: SBPBankCellType) -> SBPBankCellPresenter
    func build(cellType: SBPBankCellType, action: @escaping VoidBlock) -> SBPBankCellPresenter
}
