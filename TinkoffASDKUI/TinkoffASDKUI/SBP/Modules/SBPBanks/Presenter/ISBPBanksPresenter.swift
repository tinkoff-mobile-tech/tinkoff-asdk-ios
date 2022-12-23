//
//  ISBPBanksPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

protocol ISBPBanksPresenter {
    func viewDidLoad()

    func numberOfRows() -> Int
    func viewModel(for row: Int) -> SBPBankCellNewViewModel
}
