//
//  ISBPBanksViewController.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

protocol ISBPBanksViewController: AnyObject {
    func setupNavigationWithCloseButton()
    func setupNavigationWithBackButton()

    func showSearchBar()
    func hideSearchBar()

    func reloadTableView()
}
