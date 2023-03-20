//
//  ISBPQrViewInput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

protocol ISBPQrViewInput: AnyObject {
    func showCommonSheet(state: CommonSheetState)
    func hideCommonSheet()
    func reloadData()
    func closeView()
}
