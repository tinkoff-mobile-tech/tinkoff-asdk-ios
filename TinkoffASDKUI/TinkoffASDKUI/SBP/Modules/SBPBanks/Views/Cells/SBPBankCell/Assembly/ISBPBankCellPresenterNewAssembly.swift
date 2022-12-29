//
//  ISBPBankCellPresenterNewAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 29.12.2022.
//

protocol ISBPBankCellPresenterNewAssembly {
    func build(cellType: SBPBankCellNewType) -> SBPBankCellNewPresenter
    func build(cellType: SBPBankCellNewType, action: @escaping EmptyBlock) -> SBPBankCellNewPresenter
}
