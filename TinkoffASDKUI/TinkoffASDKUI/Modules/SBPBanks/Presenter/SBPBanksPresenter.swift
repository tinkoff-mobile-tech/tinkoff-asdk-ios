//
//  SBPBanksPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import Foundation
import TinkoffASDKCore

private enum SBPBanksScreenType {
    case startEmpty
    case startWithBanks
    case startWithFullData
}

final class SBPBanksPresenter: ISBPBanksPresenter, ISBPBanksModuleInput {

    // Dependencies
    weak var view: ISBPBanksViewController?
    private let router: ISBPBanksRouter
    private weak var output: ISBPBanksModuleOutput?

    private var moduleCompletion: PaymentResultCompletion?
    private weak var paymentSheetOutput: ISBPPaymentSheetPresenterOutput?

    private let paymentService: ISBPPaymentService?
    private let banksService: ISBPBanksService
    private let bankAppChecker: ISBPBankAppChecker
    private let bankAppOpener: ISBPBankAppOpener
    private let cellPresentersAssembly: ISBPBankCellPresenterAssembly
    private let dispatchGroup: DispatchGroup

    // Properties
    private var screenType: SBPBanksScreenType = .startEmpty
    private var allBanks = [SBPBank]()
    private var allBanksCellPresenters = [ISBPBankCellPresenter]()
    private var filteredBanksCellPresenters = [ISBPBankCellPresenter]()

    private var lastSearchedText = ""
    private var qrPayload: GetQRPayload?

    private var tempBanksResult: Result<[SBPBank], Error>?
    private var tempQrPayloadResult: Result<GetQRPayload, Error>?

    // MARK: - Initialization

    init(
        router: ISBPBanksRouter,
        output: ISBPBanksModuleOutput?,
        paymentSheetOutput: ISBPPaymentSheetPresenterOutput?,
        moduleCompletion: PaymentResultCompletion?,
        paymentService: ISBPPaymentService?,
        banksService: ISBPBanksService,
        bankAppChecker: ISBPBankAppChecker,
        bankAppOpener: ISBPBankAppOpener,
        cellPresentersAssembly: ISBPBankCellPresenterAssembly,
        dispatchGroup: DispatchGroup
    ) {
        self.router = router
        self.output = output
        self.paymentSheetOutput = paymentSheetOutput
        self.moduleCompletion = moduleCompletion
        self.paymentService = paymentService
        self.banksService = banksService
        self.bankAppChecker = bankAppChecker
        self.bankAppOpener = bankAppOpener
        self.cellPresentersAssembly = cellPresentersAssembly
        self.dispatchGroup = dispatchGroup
    }
}

// MARK: - ISBPBanksModuleInput

extension SBPBanksPresenter {
    func set(banks: [SBPBank]?) {
        if let banks = banks {
            allBanks = banks
            screenType = .startWithBanks
        }
    }

    func set(qrPayload: GetQRPayload?, banks: [SBPBank]) {
        self.qrPayload = qrPayload
        allBanks = banks
        screenType = .startWithFullData
    }
}

// MARK: - ISBPBanksPresenter

extension SBPBanksPresenter {
    func viewDidLoad() {
        switch screenType {
        case .startEmpty:
            view?.hideSearchBar()
            prepareAndShowSkeletonModels()
            loadQrPayloadAndBanks()
            view?.setupNavigationWithCloseButton()
        case .startWithBanks:
            view?.hideSearchBar()
            prepareAndShowSkeletonModels()
            loadQrPayloadWhenBanksPreloaded()
            view?.setupNavigationWithCloseButton()
        case .startWithFullData:
            setupScreen(with: allBanks)
            view?.setupNavigationWithBackButton()
        }
    }

    func closeButtonPressed() {
        routerClose(with: .cancelled())
    }

    func controllerDidDismissManually() {
        sayToOutput(.cancelled())
    }

    func prefetch(for rows: [Int]) {
        rows.forEach { cellPresenter(for: $0).startLoadingCellImageIfNeeded() }
    }

    func numberOfRows() -> Int {
        filteredBanksCellPresenters.count
    }

    func cellPresenter(for row: Int) -> ISBPBankCellPresenter {
        return filteredBanksCellPresenters[row]
    }

    func searchTextDidChange(to text: String) {
        let lowercasedText = text.lowercased()

        guard lastSearchedText != lowercasedText else { return }
        lastSearchedText = lowercasedText

        DispatchQueue.main.asyncDeduped(target: self, after: .searchDelay) { [weak self] in
            guard let self = self else { return }

            if lowercasedText.isEmpty {
                self.filteredBanksCellPresenters = self.allBanksCellPresenters
            } else {
                self.filteredBanksCellPresenters = self.allBanksCellPresenters.filter { $0.bankName.lowercased().contains(lowercasedText) }
            }
            self.view?.reloadTableView()
        }
    }

    func didSelectRow(at index: Int) {
        cellPresenter(for: index).action()
    }
}

// MARK: - ISBPPaymentSheetPresenterOutput

extension SBPBanksPresenter: ISBPPaymentSheetPresenterOutput {
    func sbpPaymentSheet(completedWith result: PaymentResult) {
        routerClose(with: result)
    }
}

// MARK: - Private methods

extension SBPBanksPresenter {
    private func prepareAndShowSkeletonModels() {
        allBanksCellPresenters = [SBPBankCellPresenter](repeatElement(cellPresentersAssembly.build(cellType: .skeleton), count: .skeletonsCount))
        filteredBanksCellPresenters = allBanksCellPresenters
        view?.reloadTableView()
    }

    private func clearCellModels() {
        allBanksCellPresenters = []
        filteredBanksCellPresenters = []
        view?.reloadTableView()
    }

    private func loadQrPayloadAndBanks() {
        loadQrPayload()
        loadBanks()

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            switch (self.tempBanksResult, self.tempQrPayloadResult) {
            case let (.success(banks), .success(qrPayload)):
                self.qrPayload = qrPayload
                self.handleSuccessLoaded(banks: banks)
                self.output?.didLoaded(sbpBanks: banks)
            case let (.failure(error), _), let (_, .failure(error)):
                self.handleFailureLoad(error: error)
            default:
                self.handleFailureLoad(error: CustomError.undefined)
            }

            self.tempBanksResult = nil
            self.tempQrPayloadResult = nil
        }
    }

    private func loadQrPayload() {
        dispatchGroup.enter()

        paymentService?.loadPaymentQr(completion: { [weak self] result in
            self?.tempQrPayloadResult = result
            self?.dispatchGroup.leave()
        })
    }

    private func loadQrPayloadWhenBanksPreloaded() {
        paymentService?.loadPaymentQr(completion: { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case let .success(qrPayload):
                    self.qrPayload = qrPayload
                    self.handleSuccessLoaded(banks: self.allBanks)
                case let .failure(error):
                    self.handleFailureLoad(error: error)
                }
            }
        })
    }

    private func loadBanks() {
        dispatchGroup.enter()

        banksService.loadBanks { [weak self] result in
            self?.tempBanksResult = result
            self?.dispatchGroup.leave()
        }
    }

    private func handleSuccessLoaded(banks: [SBPBank]) {
        allBanks = banks

        let preferredBanks = getPreferredBanks()
        if preferredBanks.isEmpty {
            view?.showSearchBar()
            allBanksCellPresenters = createCellPresenters(from: allBanks)
        } else {
            let bankButtonCellType: SBPBankCellType = .bankButton(
                imageAsset: Asset.Sbp.sbpLogo,
                name: Loc.Acquiring.SBPBanks.anotherBank
            )
            let otherBankCellPresenter = cellPresentersAssembly.build(cellType: bankButtonCellType, action: { [weak self] in
                guard let self = self else { return }

                let otherBanks = self.getNotPreferredBanks()
                self.router.show(banks: otherBanks, qrPayload: self.qrPayload, paymentSheetOutput: self)
            })
            allBanksCellPresenters = createCellPresenters(from: preferredBanks)
            allBanksCellPresenters.append(otherBankCellPresenter)
        }

        // Существует проблема анимации.
        // Скелетоны на этом экране это не отдельная вьюха или вьюхи.
        // Это те же самые ячейки что и банки, которые умеет быть скелетоном.
        // И если количество банков после загрузки оказывается меньше чем скелетонов,
        // то происходит уменьшение contentSize у tableView во вью контроллере.
        // Всвязи с чем все ячейки в момент анимации как бы едут снизу наверх (а должна быть анимация fade).
        // Поэтому приходится добавлять пустые ячейки, что бы сравнять общее количество ячеек с количеством скелетонов.
        if allBanksCellPresenters.count < .skeletonsCount {
            let blankCellsCount = Int.skeletonsCount - allBanksCellPresenters.count
            for _ in 0 ..< blankCellsCount {
                let blankPresenter = cellPresentersAssembly.build(cellType: .blank)
                allBanksCellPresenters.append(blankPresenter)
            }
        }

        filteredBanksCellPresenters = allBanksCellPresenters
        view?.reloadTableView()
    }

    private func handleFailureLoad(error: Error) {
        switch (error as NSError).code {
        case NSURLErrorNotConnectedToInternet:
            viewShowNoNetworkStub()
        default:
            viewShowServerErrorStub()
        }
    }

    private func setupScreen(with banks: [SBPBank]) {
        allBanksCellPresenters = createCellPresenters(from: banks)
        filteredBanksCellPresenters = allBanksCellPresenters
        view?.reloadTableView()
    }

    private func createCellPresenters(from banks: [SBPBank]) -> [SBPBankCellPresenter] {
        guard let paymentUrl = URL(string: qrPayload?.qrCodeData ?? ""),
              let paymentId = qrPayload?.paymentId else { return [] }

        return banks.map { bank in
            cellPresentersAssembly.build(cellType: .bank(bank), action: { [weak self] in
                self?.bankAppOpener.openBankApp(url: paymentUrl, bank, completion: { isOpened in
                    isOpened ?
                        self?.router.showPaymentSheet(paymentId: paymentId, output: self) :
                        self?.router.showDidNotFindBankAppAlert()
                })
            })
        }
    }

    private func getPreferredBanks() -> [SBPBank] {
        bankAppChecker.bankAppsPreferredByMerchant(from: allBanks)
    }

    private func getNotPreferredBanks() -> [SBPBank] {
        let preferredBanks = getPreferredBanks()
        return allBanks.filter { bank in !preferredBanks.contains(where: { $0 == bank }) }
    }

    private func viewShowNoNetworkStub() {
        clearCellModels()
        view?.showStubView(mode: .noNetwork { [weak self] in
            self?.view?.hideStubView()
            self?.prepareAndShowSkeletonModels()
            self?.loadQrPayloadAndBanks()
        })
    }

    private func viewShowServerErrorStub() {
        clearCellModels()
        view?.showStubView(mode: .serverError { [weak self] in
            self?.router.closeScreen()
        })
    }

    private func routerClose(with result: PaymentResult) {
        router.closeScreen { [weak self] in self?.sayToOutput(result)
        }
    }

    private func sayToOutput(_ result: PaymentResult) {
        moduleCompletion?(result)
        moduleCompletion = nil
        paymentSheetOutput?.sbpPaymentSheet(completedWith: result)
    }
}

// MARK: - Constants

private extension Int {
    static let skeletonsCount = 7
}

private extension TimeInterval {
    static let searchDelay = 0.3
}

// MARK: - Errors

private enum CustomError: Error {
    case undefined
}
