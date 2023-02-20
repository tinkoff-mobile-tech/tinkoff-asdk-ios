//
//  IMainFormPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation

protocol IMainFormPresenter {
    func viewDidLoad()
    func viewWasClosed()
    func numberOfRows() -> Int
    func cellType(at indexPath: IndexPath) -> MainFormCellType
    func didSelectRow(at indexPath: IndexPath)
    func commonSheetViewDidTapPrimaryButton()
}
