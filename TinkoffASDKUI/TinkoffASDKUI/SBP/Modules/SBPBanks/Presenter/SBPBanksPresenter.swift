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
    private let cellImageLoader: ICellImageLoader

    // Properties
    private var screenType: SBPBanksScreenType = .startEmpty
    private var allBanks = [SBPBank]()
    private var allBanksViewModels = [SBPBankCellNewViewModel]()
    private var filteredBanksViewModels = [SBPBankCellNewViewModel]()
    private var prefetchedUUIDs = [Int: UUID]()

    private var lastSearchedText = ""

    // MARK: - Initialization

    init(
        router: ISBPBanksRouter,
        banksService: ISBPBanksService,
        bankAppChecker: ISBPBankAppChecker,
        cellImageLoader: ICellImageLoader
    ) {
        self.router = router
        self.banksService = banksService
        self.bankAppChecker = bankAppChecker
        self.cellImageLoader = cellImageLoader
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
        switch screenType {
        case .startEmpty:
            view?.hideSearchBar()
            prepareAndShowSkeletonModels()
            loadBanks()
            view?.setupNavigationWithCloseButton()
        case .startWithData:
            setupScreen(with: allBanks)
            view?.setupNavigationWithBackButton()
        }
    }

    func closeButtonPressed() {
        router.closeScreen()
    }

    func prefetch(for rows: [Int]) {
        rows.forEach { row in
            guard let logoURL = viewModel(for: row).logoURL else { return }

            if let uuid = cellImageLoader.loadRemoteImageJustForCache(url: logoURL) {
                prefetchedUUIDs[row] = uuid
            }
        }
    }

    func cancelPrefetching(for rows: [Int]) {
        rows.forEach { row in
            if let uuid = prefetchedUUIDs[row] {
                cellImageLoader.cancelLoad(uuid: uuid)
                prefetchedUUIDs[row] = nil
            }
        }
    }

    func numberOfRows() -> Int {
        filteredBanksViewModels.count
    }

    func viewModel(for row: Int) -> SBPBankCellNewViewModel {
        return filteredBanksViewModels[row]
    }

    func searchTextDidChange(to text: String) {
        let lowercasedText = text.lowercased()

        guard lastSearchedText != lowercasedText else { return }
        lastSearchedText = lowercasedText

        DispatchQueue.main.asyncDeduped(target: self, after: 0.3) { [weak self] in
            guard let self = self else { return }

            if lowercasedText.isEmpty {
                self.filteredBanksViewModels = self.allBanksViewModels
            } else {
                self.filteredBanksViewModels = self.allBanksViewModels.filter { $0.nameLabelText.lowercased().contains(lowercasedText) }
            }
            self.view?.reloadTableView()
        }
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
    private func prepareAndShowSkeletonModels() {
        allBanksViewModels = [SBPBankCellNewViewModel](repeatElement(SBPBankCellNewViewModel.skeletonModel, count: 7))
        filteredBanksViewModels = allBanksViewModels
        view?.reloadTableView()
    }

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
            view?.showSearchBar()
            allBanksViewModels = createViewModels(from: allBanks)
        } else {
            let otherBankViewModel = SBPBankCellNewViewModel(nameLabelText: Loc.Acquiring.SBPBanks.anotherBank, imageAsset: Asset.Sbp.sbpLogo)
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
        banks.map { SBPBankCellNewViewModel(nameLabelText: $0.name, logoURL: $0.logoURL, schema: $0.schema) }
    }

    private func getPreferredBanks() -> [SBPBank] {
        bankAppChecker.bankAppsPreferredByMerchant(from: allBanks)
    }

    private func getNotPreferredBanks() -> [SBPBank] {
        let preferredBanks = getPreferredBanks()
        return allBanks.filter { bank in !preferredBanks.contains(where: { $0 == bank }) }
    }
}
