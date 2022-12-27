//
//  SBPBanksPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import TinkoffASDKCore

private enum SBPBanksScreenType {
    case startEmpty
    case startWithData
}

final class SBPBanksPresenter: ISBPBanksPresenter, ISBPBanksModuleInput {

    // Dependencies
    weak var view: ISBPBanksViewController?
    private let router: ISBPBanksRouter

    private let banksService: ISBPBanksService
    private let bankAppChecker: ISBPBankAppChecker

    // Properties
    private var screenType: SBPBanksScreenType = .startEmpty
    private var allBanks = [SBPBank]()
    private var allBanksViewModels = [SBPBankCellNewViewModel]()
    private var filteredBanksViewModels = [SBPBankCellNewViewModel]()

    // MARK: - Initialization

    init(
        router: ISBPBanksRouter,
        banksService: ISBPBanksService,
        bankAppChecker: ISBPBankAppChecker
    ) {
        self.router = router
        self.banksService = banksService
        self.bankAppChecker = bankAppChecker
    }
}

// MARK: - ISBPBanksModuleInput

extension SBPBanksPresenter {
    func set(banks: [SBPBank]) {
        allBanks = banks
        screenType = .startWithData
    }
}

// MARK: - ISBPBanksPresenter

extension SBPBanksPresenter {
    func viewDidLoad() {
        if screenType == .startEmpty {
            loadBanks()
            view?.setupNavigationWithCloseButton()
        } else {
            setupScreen(with: allBanks)
            view?.setupNavigationWithBackButton()
        }
    }

    func closeButtonPressed() {
        router.closeScreen()
    }

    func numberOfRows() -> Int {
        filteredBanksViewModels.count
    }

    func viewModel(for row: Int) -> SBPBankCellNewViewModel {
        filteredBanksViewModels[row]
    }

    func searchTextDidChange(to text: String) {
        let lowecasedText = text.lowercased()
        if lowecasedText.isEmpty {
            filteredBanksViewModels = allBanksViewModels
        } else {
            filteredBanksViewModels = allBanksViewModels.filter { $0.nameLabelText.lowercased().contains(lowecasedText) }
        }
        view?.reloadTableView()
    }

    func didSelectRow(at index: Int) {
        let lastIndex = filteredBanksViewModels.count - 1
        let isLastAnotherBankViewModel = filteredBanksViewModels.last?.nameLabelText == Loc.Acquiring.SBPBanks.anotherBank
        if screenType == .startEmpty, index == lastIndex, isLastAnotherBankViewModel {
            let otherBanks = getNotPreferredBanks()
            router.show(banks: otherBanks)
        } else {
//            bankAppChecker.openBankApp(someBank)
        }
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
                    self.handleSuccessLoaded(banks: banks)
                }
            case let .failure(error):
                print(error)
            }
        }
    }

    private func handleSuccessLoaded(banks: [SBPBank]) {
        allBanks = banks

        let preferredBanks = getPreferredBanks()
        if preferredBanks.isEmpty {
            allBanksViewModels = createViewModels(from: allBanks)
        } else {
            view?.hideSearchBar()

            let otherBankViewModel = SBPBankCellNewViewModel(nameLabelText: Loc.Acquiring.SBPBanks.anotherBank, logoURL: nil)
            allBanksViewModels = createViewModels(from: preferredBanks)
            allBanksViewModels.append(otherBankViewModel)
        }

        filteredBanksViewModels = allBanksViewModels
        view?.reloadTableView()
    }

    private func setupScreen(with banks: [SBPBank]) {
        allBanksViewModels = createViewModels(from: banks)
        filteredBanksViewModels = allBanksViewModels
        view?.reloadTableView()
    }

    private func createViewModels(from banks: [SBPBank]) -> [SBPBankCellNewViewModel] {
        banks.map { SBPBankCellNewViewModel(nameLabelText: $0.name, logoURL: $0.logoURL) }
    }

    private func getPreferredBanks() -> [SBPBank] {
        bankAppChecker.bankAppsPreferredByMerchant(from: allBanks)
    }

    private func getNotPreferredBanks() -> [SBPBank] {
        let preferredBanks = getPreferredBanks()
        return allBanks.filter { bank in !preferredBanks.contains(where: { $0 == bank }) }
    }
}
