//
//  SBPBanksPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import TinkoffASDKCore

final class SBPBanksPresenter: ISBPBanksPresenter {

    // Dependencies
    weak var view: ISBPBanksViewController?

    private let banksService: ISBPBanksService

    // Properties
    private var allBanksViewModels = [SBPBankCellNewViewModel]()

    // MARK: - Initialization

    init(banksService: ISBPBanksService) {
        self.banksService = banksService
    }
}

// MARK: - ISBPBanksPresenter

extension SBPBanksPresenter {
    func viewDidLoad() {
        loadBanks()
    }

    func numberOfRows() -> Int {
        allBanksViewModels.count
    }

    func viewModel(for row: Int) -> SBPBankCellNewViewModel {
        allBanksViewModels[row]
    }
}

// MARK: - Private methods

extension SBPBanksPresenter {
    private func loadBanks() {
        banksService.loadBanks { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(banks):
                DispatchQueue.main.async {
                    self.allBanksViewModels = banks.map { SBPBankCellNewViewModel(nameLabelText: $0.name, logoURL: $0.logoURL) }
                    self.view?.reloadTableView()
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}
