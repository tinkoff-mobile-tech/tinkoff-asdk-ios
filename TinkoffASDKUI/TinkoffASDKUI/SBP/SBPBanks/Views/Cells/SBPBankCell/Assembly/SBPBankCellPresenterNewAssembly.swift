//
//  SBPBankCellPresenterNewAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 29.12.2022.
//

final class SBPBankCellPresenterNewAssembly: ISBPBankCellPresenterNewAssembly {

    // Dependencies
    private let cellImageLoader: ICellImageLoader

    // MARK: - Initialization

    init(cellImageLoader: ICellImageLoader) {
        self.cellImageLoader = cellImageLoader
    }

    // MARK: - ISBPBankCellNewAssembly

    func build(cellType: SBPBankCellNewType) -> SBPBankCellNewPresenter {
        build(cellType: cellType, action: {})
    }

    func build(cellType: SBPBankCellNewType, action: @escaping VoidBlock) -> SBPBankCellNewPresenter {
        return SBPBankCellNewPresenter(cellType: cellType, action: action, cellImageLoader: cellImageLoader)
    }
}
