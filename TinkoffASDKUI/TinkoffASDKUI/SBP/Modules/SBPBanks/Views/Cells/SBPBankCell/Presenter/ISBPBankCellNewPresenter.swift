//
//  ISBPBankCellNewPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 29.12.2022.
//

import TinkoffASDKCore

protocol ISBPBankCellNewPresenter: AnyObject {
    var cell: ISBPBankCellNew? { get set }

    var bankName: String { get }

    var action: VoidBlock { get }

    func startLoadingCellImageIfNeeded()
}
