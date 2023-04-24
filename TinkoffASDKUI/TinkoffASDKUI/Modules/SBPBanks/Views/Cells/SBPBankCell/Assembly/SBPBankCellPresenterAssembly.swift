//
//  SBPBankCellPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 29.12.2022.
//

final class SBPBankCellPresenterAssembly: ISBPBankCellPresenterAssembly {

    // Dependencies
    private let cellImageLoader: ICellImageLoader

    // MARK: - Initialization

    init(cellImageLoader: ICellImageLoader) {
        self.cellImageLoader = cellImageLoader
    }

    // MARK: - ISBPBankCellAssembly

    func build(cellType: SBPBankCellType) -> ISBPBankCellPresenter {
        build(cellType: cellType, action: {})
    }

    func build(cellType: SBPBankCellType, action: @escaping VoidBlock) -> ISBPBankCellPresenter {
        return SBPBankCellPresenter(cellType: cellType, action: action, cellImageLoader: cellImageLoader)
    }
}
