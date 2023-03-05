//
//  MainFormDataStateLoader.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 23.02.2023.
//

import Foundation
import TinkoffASDKCore

final class MainFormDataStateLoader {
    // MARK: Internal Types

    private typealias NextMethod = () -> MainFormPaymentMethod?
    private typealias ReceiveCards = (_ cards: [PaymentCard]) -> Void
    private typealias ReceiveSBPBanks = (_ allBanks: [SBPBank]) -> Void
    private typealias CanBecomeCompletion = (_ canBecomePrimaryMethod: Bool) -> Void
    private typealias PrimaryMethodCompletion = (_ primaryMethod: MainFormPaymentMethod) -> Void

    // MARK: Dependencies

    private let terminalService: IAcquiringTerminalService
    private let cardsController: ICardsController?
    private let sbpBanksService: ISBPBanksService
    private let sbpBankAppChecker: ISBPBankAppChecker
    private let tinkoffPayAppChecker: ITinkoffPayAppChecker

    // MARK: Init

    init(
        terminalService: IAcquiringTerminalService,
        cardsController: ICardsController?,
        sbpBanksService: ISBPBanksService,
        sbpBankAppChecker: ISBPBankAppChecker,
        tinkoffPayAppChecker: ITinkoffPayAppChecker
    ) {
        self.terminalService = terminalService
        self.cardsController = cardsController
        self.sbpBanksService = sbpBanksService
        self.sbpBankAppChecker = sbpBankAppChecker
        self.tinkoffPayAppChecker = tinkoffPayAppChecker
    }
}

// MARK: - IMainFormDataStateLoader

extension MainFormDataStateLoader: IMainFormDataStateLoader {
    func loadState(
        for paymentFlow: PaymentFlow,
        completion: @escaping (Result<MainFormDataState, Error>) -> Void
    ) {
        let completion: (Result<MainFormDataState, Error>) -> Void = { result in
            DispatchQueue.performOnMain { completion(result) }
        }

        terminalService.getTerminalPayMethods { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(payload):
                self.resolveState(paymentFlow: paymentFlow, terminalInfo: payload.terminalInfo, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - State Resolving

extension MainFormDataStateLoader {
    private func resolveState(
        paymentFlow: PaymentFlow,
        terminalInfo: TerminalInfo,
        completion: @escaping (Result<MainFormDataState, Error>) -> Void
    ) {
        let availableMethods = (CollectionOfOne(.card) + terminalInfo.mainFormMethods)
            .filter { $0.isAvailable(for: paymentFlow) }
            .sorted(by: <)

        var methodsIterator = availableMethods.makeIterator()
        var receivedCards: [PaymentCard]?
        var receivedSBPBanks: [SBPBank]?

        let nextMethod: NextMethod = { methodsIterator.next() }
        let receiveCards: ReceiveCards = { receivedCards = $0 }
        let receiveSBPBanks: ReceiveSBPBanks = { receivedSBPBanks = $0 }

        let primaryMethodCompletion: PrimaryMethodCompletion = { primaryMethod in
            let state = MainFormDataState(
                primaryPaymentMethod: primaryMethod,
                otherPaymentMethods: availableMethods.filter { $0 != primaryMethod },
                cards: receivedCards,
                sbpBanks: receivedSBPBanks
            )

            completion(.success(state))
        }

        resolvePrimaryMethod(
            terminalInfo: terminalInfo,
            nextMethod: nextMethod,
            receiveCards: receiveCards,
            receiveSBPBanks: receiveSBPBanks,
            completion: primaryMethodCompletion
        )
    }

    // MARK: Primary Method Resolving

    private func resolvePrimaryMethod(
        terminalInfo: TerminalInfo,
        nextMethod: @escaping NextMethod,
        receiveCards: @escaping ReceiveCards,
        receiveSBPBanks: @escaping ReceiveSBPBanks,
        completion: @escaping PrimaryMethodCompletion
    ) {
        guard let currentMethod = nextMethod() else {
            return completion(.card)
        }

        let canBecomeCompletion: CanBecomeCompletion = { [weak self] canBecomePrimaryMethod in
            guard let self = self else { return }

            if canBecomePrimaryMethod {
                return completion(currentMethod)
            }

            self.resolvePrimaryMethod(
                terminalInfo: terminalInfo,
                nextMethod: nextMethod,
                receiveCards: receiveCards,
                receiveSBPBanks: receiveSBPBanks,
                completion: completion
            )
        }

        switch currentMethod {
        case .tinkoffPay:
            canTinkoffPayBecomePrimaryMethod(completion: canBecomeCompletion)
        case .card:
            canSavedCardBecomePrimaryMethod(terminalInfo: terminalInfo, receiveCards: receiveCards, completion: canBecomeCompletion)
        case .sbp:
            canSBPBecomePrimaryMethod(receiveSBPBanks: receiveSBPBanks, completion: canBecomeCompletion)
        }
    }

    // MARK: Tinkoff Pay

    private func canTinkoffPayBecomePrimaryMethod(completion: @escaping CanBecomeCompletion) {
        DispatchQueue.performOnMain { [weak self] in
            guard let self = self else { return }
            completion(self.tinkoffPayAppChecker.isTinkoffPayAppInstalled())
        }
    }

    // MARK: Saved Cards

    private func canSavedCardBecomePrimaryMethod(
        terminalInfo: TerminalInfo,
        receiveCards: @escaping ReceiveCards,
        completion: @escaping CanBecomeCompletion
    ) {
        guard terminalInfo.addCardScheme,
              let cardsController = cardsController else {
            return completion(false)
        }

        cardsController.getActiveCards { result in
            switch result {
            case let .success(cards):
                receiveCards(cards)
                completion(!cards.isEmpty)
            case .failure:
                completion(false)
            }
        }
    }

    // MARK: SBP

    private func canSBPBecomePrimaryMethod(
        receiveSBPBanks: @escaping ReceiveSBPBanks,
        completion: @escaping CanBecomeCompletion
    ) {
        sbpBanksService.loadBanks { [weak self] result in
            DispatchQueue.performOnMain {
                guard let self = self else { return }

                switch result {
                case let .success(allBanks):
                    let preferredBanks = self.sbpBankAppChecker.bankAppsPreferredByMerchant(from: allBanks)
                    receiveSBPBanks(allBanks)
                    completion(!preferredBanks.isEmpty)
                case .failure:
                    completion(false)
                }
            }
        }
    }
}

// MARK: - PaymentFlow + Helpers

private extension MainFormPaymentMethod {
    func isAvailable(for paymentFlow: PaymentFlow) -> Bool {
        switch (self, paymentFlow) {
        case (.tinkoffPay, .finish):
            return false
        default:
            return true
        }
    }
}

// MARK: - TerminalInfo + Helpers

private extension TerminalInfo {
    var mainFormMethods: [MainFormPaymentMethod] {
        payMethods.compactMap { terminalMethod in
            switch terminalMethod {
            case .yandexPay:
                return nil
            case .sbp:
                return .sbp
            case let .tinkoffPay(version):
                return .tinkoffPay(version: version)
            }
        }
    }
}
