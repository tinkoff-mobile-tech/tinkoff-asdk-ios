//
//  AcquiringSdkMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 26.04.2023.
//

import Foundation

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class AcquiringSdkMock: IAcquiringSdk {

    // MARK: - initPayment

    typealias InitPaymentArguments = (data: PaymentInitData, completion: (_ result: Result<InitPayload, Error>) -> Void)

    var initPaymentCallsCount = 0
    var initPaymentReceivedArguments: InitPaymentArguments?
    var initPaymentReceivedInvocations: [InitPaymentArguments?] = []
    var initPaymentCompletionClosureInput: Result<InitPayload, Error>?
    var initPaymentReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func initPayment(data: PaymentInitData, completion: @escaping (_ result: Result<InitPayload, Error>) -> Void) -> Cancellable {
        initPaymentCallsCount += 1
        let arguments = (data, completion)
        initPaymentReceivedArguments = arguments
        initPaymentReceivedInvocations.append(arguments)
        if let initPaymentCompletionClosureInput = initPaymentCompletionClosureInput {
            completion(initPaymentCompletionClosureInput)
        }
        return initPaymentReturnValue
    }

    // MARK: - finishAuthorize

    typealias FinishAuthorizeArguments = (data: FinishAuthorizeData, completion: (_ result: Result<FinishAuthorizePayload, Error>) -> Void)

    var finishAuthorizeCallsCount = 0
    var finishAuthorizeReceivedArguments: FinishAuthorizeArguments?
    var finishAuthorizeReceivedInvocations: [FinishAuthorizeArguments?] = []
    var finishAuthorizeCompletionClosureInput: Result<FinishAuthorizePayload, Error>?
    var finishAuthorizeReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func finishAuthorize(data: FinishAuthorizeData, completion: @escaping (_ result: Result<FinishAuthorizePayload, Error>) -> Void) -> Cancellable {
        finishAuthorizeCallsCount += 1
        let arguments = (data, completion)
        finishAuthorizeReceivedArguments = arguments
        finishAuthorizeReceivedInvocations.append(arguments)
        if let finishAuthorizeCompletionClosureInput = finishAuthorizeCompletionClosureInput {
            completion(finishAuthorizeCompletionClosureInput)
        }
        return finishAuthorizeReturnValue
    }

    // MARK: - charge

    typealias ChargeArguments = (data: ChargeData, completion: (_ result: Result<ChargePayload, Error>) -> Void)

    var chargeCallsCount = 0
    var chargeReceivedArguments: ChargeArguments?
    var chargeReceivedInvocations: [ChargeArguments?] = []
    var chargeCompletionClosureInput: Result<ChargePayload, Error>?
    var chargeReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func charge(data: ChargeData, completion: @escaping (_ result: Result<ChargePayload, Error>) -> Void) -> Cancellable {
        chargeCallsCount += 1
        let arguments = (data, completion)
        chargeReceivedArguments = arguments
        chargeReceivedInvocations.append(arguments)
        if let chargeCompletionClosureInput = chargeCompletionClosureInput {
            completion(chargeCompletionClosureInput)
        }
        return chargeReturnValue
    }

    // MARK: - getPaymentState

    typealias GetPaymentStateArguments = (data: GetPaymentStateData, completion: (_ result: Result<GetPaymentStatePayload, Error>) -> Void)

    var getPaymentStateCallsCount = 0
    var getPaymentStateReceivedArguments: GetPaymentStateArguments?
    var getPaymentStateReceivedInvocations: [GetPaymentStateArguments?] = []
    var getPaymentStateCompletionClosureInput: Result<GetPaymentStatePayload, Error>?
    var getPaymentStateReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getPaymentState(data: GetPaymentStateData, completion: @escaping (_ result: Result<GetPaymentStatePayload, Error>) -> Void) -> Cancellable {
        getPaymentStateCallsCount += 1
        let arguments = (data, completion)
        getPaymentStateReceivedArguments = arguments
        getPaymentStateReceivedInvocations.append(arguments)
        if let getPaymentStateCompletionClosureInput = getPaymentStateCompletionClosureInput {
            completion(getPaymentStateCompletionClosureInput)
        }
        return getPaymentStateReturnValue
    }

    // MARK: - loadSBPBanks

    typealias LoadSBPBanksArguments = (Result<GetSBPBanksPayload, Error>) -> Void

    var loadSBPBanksCallsCount = 0
    var loadSBPBanksReceivedArguments: LoadSBPBanksArguments?
    var loadSBPBanksReceivedInvocations: [LoadSBPBanksArguments?] = []
    var loadSBPBanksCompletionClosureInput: Result<GetSBPBanksPayload, Error>?
    var loadSBPBanksReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func loadSBPBanks(completion: @escaping (Result<GetSBPBanksPayload, Error>) -> Void) -> Cancellable {
        loadSBPBanksCallsCount += 1
        let arguments = completion
        loadSBPBanksReceivedArguments = arguments
        loadSBPBanksReceivedInvocations.append(arguments)
        if let loadSBPBanksCompletionClosureInput = loadSBPBanksCompletionClosureInput {
            completion(loadSBPBanksCompletionClosureInput)
        }
        return loadSBPBanksReturnValue
    }

    // MARK: - getQR

    typealias GetQRArguments = (data: GetQRData, completion: (_ result: Result<GetQRPayload, Error>) -> Void)

    var getQRCallsCount = 0
    var getQRReceivedArguments: GetQRArguments?
    var getQRReceivedInvocations: [GetQRArguments?] = []
    var getQRCompletionClosureInput: Result<GetQRPayload, Error>?
    var getQRReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getQR(data: GetQRData, completion: @escaping (_ result: Result<GetQRPayload, Error>) -> Void) -> Cancellable {
        getQRCallsCount += 1
        let arguments = (data, completion)
        getQRReceivedArguments = arguments
        getQRReceivedInvocations.append(arguments)
        if let getQRCompletionClosureInput = getQRCompletionClosureInput {
            completion(getQRCompletionClosureInput)
        }
        return getQRReturnValue
    }

    // MARK: - getStaticQR

    typealias GetStaticQRArguments = (data: GetQRDataType, completion: (_ result: Result<GetStaticQRPayload, Error>) -> Void)

    var getStaticQRCallsCount = 0
    var getStaticQRReceivedArguments: GetStaticQRArguments?
    var getStaticQRReceivedInvocations: [GetStaticQRArguments?] = []
    var getStaticQRCompletionClosureInput: Result<GetStaticQRPayload, Error>?
    var getStaticQRReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getStaticQR(data: GetQRDataType, completion: @escaping (_ result: Result<GetStaticQRPayload, Error>) -> Void) -> Cancellable {
        getStaticQRCallsCount += 1
        let arguments = (data, completion)
        getStaticQRReceivedArguments = arguments
        getStaticQRReceivedInvocations.append(arguments)
        if let getStaticQRCompletionClosureInput = getStaticQRCompletionClosureInput {
            completion(getStaticQRCompletionClosureInput)
        }
        return getStaticQRReturnValue
    }

    // MARK: - getTerminalPayMethods

    typealias GetTerminalPayMethodsArguments = (Result<GetTerminalPayMethodsPayload, Error>) -> Void

    var getTerminalPayMethodsCallsCount = 0
    var getTerminalPayMethodsReceivedArguments: GetTerminalPayMethodsArguments?
    var getTerminalPayMethodsReceivedInvocations: [GetTerminalPayMethodsArguments?] = []
    var getTerminalPayMethodsCompletionClosureInput: Result<GetTerminalPayMethodsPayload, Error>?
    var getTerminalPayMethodsReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getTerminalPayMethods(completion: @escaping (Result<GetTerminalPayMethodsPayload, Error>) -> Void) -> Cancellable {
        getTerminalPayMethodsCallsCount += 1
        let arguments = completion
        getTerminalPayMethodsReceivedArguments = arguments
        getTerminalPayMethodsReceivedInvocations.append(arguments)
        if let getTerminalPayMethodsCompletionClosureInput = getTerminalPayMethodsCompletionClosureInput {
            completion(getTerminalPayMethodsCompletionClosureInput)
        }
        return getTerminalPayMethodsReturnValue
    }

    // MARK: - check3DSVersion

    typealias Check3DSVersionArguments = (data: Check3DSVersionData, completion: (_ result: Result<Check3DSVersionPayload, Error>) -> Void)

    var check3DSVersionCallsCount = 0
    var check3DSVersionReceivedArguments: Check3DSVersionArguments?
    var check3DSVersionReceivedInvocations: [Check3DSVersionArguments?] = []
    var check3DSVersionCompletionClosureInput: Result<Check3DSVersionPayload, Error>?
    var check3DSVersionReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func check3DSVersion(data: Check3DSVersionData, completion: @escaping (_ result: Result<Check3DSVersionPayload, Error>) -> Void) -> Cancellable {
        check3DSVersionCallsCount += 1
        let arguments = (data, completion)
        check3DSVersionReceivedArguments = arguments
        check3DSVersionReceivedInvocations.append(arguments)
        if let check3DSVersionCompletionClosureInput = check3DSVersionCompletionClosureInput {
            completion(check3DSVersionCompletionClosureInput)
        }
        return check3DSVersionReturnValue
    }

    // MARK: - confirmation3DSTerminationURL

    var confirmation3DSTerminationURLCallsCount = 0
    var confirmation3DSTerminationURLReturnValue: URL!

    func confirmation3DSTerminationURL() -> URL {
        confirmation3DSTerminationURLCallsCount += 1
        return confirmation3DSTerminationURLReturnValue
    }

    // MARK: - confirmation3DSTerminationV2URL

    var confirmation3DSTerminationV2URLCallsCount = 0
    var confirmation3DSTerminationV2URLReturnValue: URL!

    func confirmation3DSTerminationV2URL() -> URL {
        confirmation3DSTerminationV2URLCallsCount += 1
        return confirmation3DSTerminationV2URLReturnValue
    }

    // MARK: - confirmation3DSCompleteV2URL

    var confirmation3DSCompleteV2URLCallsCount = 0
    var confirmation3DSCompleteV2URLReturnValue: URL!

    func confirmation3DSCompleteV2URL() -> URL {
        confirmation3DSCompleteV2URLCallsCount += 1
        return confirmation3DSCompleteV2URLReturnValue
    }

    // MARK: - createChecking3DSURL

    typealias CreateChecking3DSURLArguments = Checking3DSURLData

    var createChecking3DSURLThrowableError: Error?
    var createChecking3DSURLCallsCount = 0
    var createChecking3DSURLReceivedArguments: CreateChecking3DSURLArguments?
    var createChecking3DSURLReceivedInvocations: [CreateChecking3DSURLArguments?] = []
    var createChecking3DSURLReturnValue: URLRequest!

    func createChecking3DSURL(data: Checking3DSURLData) throws -> URLRequest {
        if let error = createChecking3DSURLThrowableError {
            throw error
        }
        createChecking3DSURLCallsCount += 1
        let arguments = data
        createChecking3DSURLReceivedArguments = arguments
        createChecking3DSURLReceivedInvocations.append(arguments)
        return createChecking3DSURLReturnValue
    }

    // MARK: - createConfirmation3DSRequest

    typealias CreateConfirmation3DSRequestArguments = Confirmation3DSData

    var createConfirmation3DSRequestThrowableError: Error?
    var createConfirmation3DSRequestCallsCount = 0
    var createConfirmation3DSRequestReceivedArguments: CreateConfirmation3DSRequestArguments?
    var createConfirmation3DSRequestReceivedInvocations: [CreateConfirmation3DSRequestArguments?] = []
    var createConfirmation3DSRequestReturnValue: URLRequest!

    func createConfirmation3DSRequest(data: Confirmation3DSData) throws -> URLRequest {
        if let error = createConfirmation3DSRequestThrowableError {
            throw error
        }
        createConfirmation3DSRequestCallsCount += 1
        let arguments = data
        createConfirmation3DSRequestReceivedArguments = arguments
        createConfirmation3DSRequestReceivedInvocations.append(arguments)
        return createConfirmation3DSRequestReturnValue
    }

    // MARK: - createConfirmation3DSRequestACS

    typealias CreateConfirmation3DSRequestACSArguments = (data: Confirmation3DSDataACS, messageVersion: String)

    var createConfirmation3DSRequestACSThrowableError: Error?
    var createConfirmation3DSRequestACSCallsCount = 0
    var createConfirmation3DSRequestACSReceivedArguments: CreateConfirmation3DSRequestACSArguments?
    var createConfirmation3DSRequestACSReceivedInvocations: [CreateConfirmation3DSRequestACSArguments?] = []
    var createConfirmation3DSRequestACSReturnValue: URLRequest!

    func createConfirmation3DSRequestACS(data: Confirmation3DSDataACS, messageVersion: String) throws -> URLRequest {
        if let error = createConfirmation3DSRequestACSThrowableError {
            throw error
        }
        createConfirmation3DSRequestACSCallsCount += 1
        let arguments = (data, messageVersion)
        createConfirmation3DSRequestACSReceivedArguments = arguments
        createConfirmation3DSRequestACSReceivedInvocations.append(arguments)
        return createConfirmation3DSRequestACSReturnValue
    }

    // MARK: - submit3DSAuthorizationV2

    typealias Submit3DSAuthorizationV2Arguments = (data: CresData, completion: (_ result: Result<GetPaymentStatePayload, Error>) -> Void)

    var submit3DSAuthorizationV2CallsCount = 0
    var submit3DSAuthorizationV2ReceivedArguments: Submit3DSAuthorizationV2Arguments?
    var submit3DSAuthorizationV2ReceivedInvocations: [Submit3DSAuthorizationV2Arguments?] = []
    var submit3DSAuthorizationV2CompletionClosureInput: Result<GetPaymentStatePayload, Error>?
    var submit3DSAuthorizationV2ReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func submit3DSAuthorizationV2(data: CresData, completion: @escaping (_ result: Result<GetPaymentStatePayload, Error>) -> Void) -> Cancellable {
        submit3DSAuthorizationV2CallsCount += 1
        let arguments = (data, completion)
        submit3DSAuthorizationV2ReceivedArguments = arguments
        submit3DSAuthorizationV2ReceivedInvocations.append(arguments)
        if let submit3DSAuthorizationV2CompletionClosureInput = submit3DSAuthorizationV2CompletionClosureInput {
            completion(submit3DSAuthorizationV2CompletionClosureInput)
        }
        return submit3DSAuthorizationV2ReturnValue
    }

    // MARK: - getCertsConfig

    typealias GetCertsConfigArguments = (Result<Get3DSAppBasedCertsConfigPayload, Error>) -> Void

    var getCertsConfigCallsCount = 0
    var getCertsConfigReceivedArguments: GetCertsConfigArguments?
    var getCertsConfigReceivedInvocations: [GetCertsConfigArguments?] = []
    var getCertsConfigCompletionClosureInput: Result<Get3DSAppBasedCertsConfigPayload, Error>?
    var getCertsConfigReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getCertsConfig(completion: @escaping (Result<Get3DSAppBasedCertsConfigPayload, Error>) -> Void) -> Cancellable {
        getCertsConfigCallsCount += 1
        let arguments = completion
        getCertsConfigReceivedArguments = arguments
        getCertsConfigReceivedInvocations.append(arguments)
        if let getCertsConfigCompletionClosureInput = getCertsConfigCompletionClosureInput {
            completion(getCertsConfigCompletionClosureInput)
        }
        return getCertsConfigReturnValue
    }

    // MARK: - getTinkoffPayLink

    typealias GetTinkoffPayLinkArguments = (data: GetTinkoffLinkData, completion: (Result<GetTinkoffLinkPayload, Error>) -> Void)

    var getTinkoffPayLinkCallsCount = 0
    var getTinkoffPayLinkReceivedArguments: GetTinkoffPayLinkArguments?
    var getTinkoffPayLinkReceivedInvocations: [GetTinkoffPayLinkArguments?] = []
    var getTinkoffPayLinkCompletionClosureInput: Result<GetTinkoffLinkPayload, Error>?
    var getTinkoffPayLinkReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getTinkoffPayLink(data: GetTinkoffLinkData, completion: @escaping (Result<GetTinkoffLinkPayload, Error>) -> Void) -> Cancellable {
        getTinkoffPayLinkCallsCount += 1
        let arguments = (data, completion)
        getTinkoffPayLinkReceivedArguments = arguments
        getTinkoffPayLinkReceivedInvocations.append(arguments)
        if let getTinkoffPayLinkCompletionClosureInput = getTinkoffPayLinkCompletionClosureInput {
            completion(getTinkoffPayLinkCompletionClosureInput)
        }
        return getTinkoffPayLinkReturnValue
    }

    // MARK: - getTinkoffPayStatus

    typealias GetTinkoffPayStatusArguments = (Result<GetTinkoffPayStatusPayload, Error>) -> Void

    var getTinkoffPayStatusCallsCount = 0
    var getTinkoffPayStatusReceivedArguments: GetTinkoffPayStatusArguments?
    var getTinkoffPayStatusReceivedInvocations: [GetTinkoffPayStatusArguments?] = []
    var getTinkoffPayStatusCompletionClosureInput: Result<GetTinkoffPayStatusPayload, Error>?
    var getTinkoffPayStatusReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getTinkoffPayStatus(completion: @escaping (Result<GetTinkoffPayStatusPayload, Error>) -> Void) -> Cancellable {
        getTinkoffPayStatusCallsCount += 1
        let arguments = completion
        getTinkoffPayStatusReceivedArguments = arguments
        getTinkoffPayStatusReceivedInvocations.append(arguments)
        if let getTinkoffPayStatusCompletionClosureInput = getTinkoffPayStatusCompletionClosureInput {
            completion(getTinkoffPayStatusCompletionClosureInput)
        }
        return getTinkoffPayStatusReturnValue
    }

    // MARK: - addCard

    typealias AddCardArguments = (data: AddCardData, completion: (_ result: Result<AddCardPayload, Error>) -> Void)

    var addCardCallsCount = 0
    var addCardReceivedArguments: AddCardArguments?
    var addCardReceivedInvocations: [AddCardArguments?] = []
    var addCardCompletionClosureInput: Result<AddCardPayload, Error>?
    var addCardReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func addCard(data: AddCardData, completion: @escaping (_ result: Result<AddCardPayload, Error>) -> Void) -> Cancellable {
        addCardCallsCount += 1
        let arguments = (data, completion)
        addCardReceivedArguments = arguments
        addCardReceivedInvocations.append(arguments)
        if let addCardCompletionClosureInput = addCardCompletionClosureInput {
            completion(addCardCompletionClosureInput)
        }
        return addCardReturnValue
    }

    // MARK: - attachCard

    typealias AttachCardArguments = (data: AttachCardData, completion: (_ result: Result<AttachCardPayload, Error>) -> Void)

    var attachCardCallsCount = 0
    var attachCardReceivedArguments: AttachCardArguments?
    var attachCardReceivedInvocations: [AttachCardArguments?] = []
    var attachCardCompletionClosureInput: Result<AttachCardPayload, Error>?
    var attachCardReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func attachCard(data: AttachCardData, completion: @escaping (_ result: Result<AttachCardPayload, Error>) -> Void) -> Cancellable {
        attachCardCallsCount += 1
        let arguments = (data, completion)
        attachCardReceivedArguments = arguments
        attachCardReceivedInvocations.append(arguments)
        if let attachCardCompletionClosureInput = attachCardCompletionClosureInput {
            completion(attachCardCompletionClosureInput)
        }
        return attachCardReturnValue
    }

    // MARK: - getAddCardState

    typealias GetAddCardStateArguments = (data: GetAddCardStateData, completion: (Result<GetAddCardStatePayload, Error>) -> Void)

    var getAddCardStateCallsCount = 0
    var getAddCardStateReceivedArguments: GetAddCardStateArguments?
    var getAddCardStateReceivedInvocations: [GetAddCardStateArguments?] = []
    var getAddCardStateCompletionClosureInput: Result<GetAddCardStatePayload, Error>?
    var getAddCardStateReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getAddCardState(data: GetAddCardStateData, completion: @escaping (Result<GetAddCardStatePayload, Error>) -> Void) -> Cancellable {
        getAddCardStateCallsCount += 1
        let arguments = (data, completion)
        getAddCardStateReceivedArguments = arguments
        getAddCardStateReceivedInvocations.append(arguments)
        if let getAddCardStateCompletionClosureInput = getAddCardStateCompletionClosureInput {
            completion(getAddCardStateCompletionClosureInput)
        }
        return getAddCardStateReturnValue
    }

    // MARK: - getCardList

    typealias GetCardListArguments = (data: GetCardListData, completion: (_ result: Result<[PaymentCard], Error>) -> Void)

    var getCardListCallsCount = 0
    var getCardListReceivedArguments: GetCardListArguments?
    var getCardListReceivedInvocations: [GetCardListArguments?] = []
    var getCardListCompletionClosureInput: Result<[PaymentCard], Error>?
    var getCardListReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func getCardList(data: GetCardListData, completion: @escaping (_ result: Result<[PaymentCard], Error>) -> Void) -> Cancellable {
        getCardListCallsCount += 1
        let arguments = (data, completion)
        getCardListReceivedArguments = arguments
        getCardListReceivedInvocations.append(arguments)
        if let getCardListCompletionClosureInput = getCardListCompletionClosureInput {
            completion(getCardListCompletionClosureInput)
        }
        return getCardListReturnValue
    }

    // MARK: - removeCard

    typealias RemoveCardArguments = (data: RemoveCardData, completion: (_ result: Result<RemoveCardPayload, Error>) -> Void)

    var removeCardCallsCount = 0
    var removeCardReceivedArguments: RemoveCardArguments?
    var removeCardReceivedInvocations: [RemoveCardArguments?] = []
    var removeCardCompletionClosureInput: Result<RemoveCardPayload, Error>?
    var removeCardReturnValue: Cancellable = CancellableMock()

    @discardableResult
    func removeCard(data: RemoveCardData, completion: @escaping (_ result: Result<RemoveCardPayload, Error>) -> Void) -> Cancellable {
        removeCardCallsCount += 1
        let arguments = (data, completion)
        removeCardReceivedArguments = arguments
        removeCardReceivedInvocations.append(arguments)
        if let removeCardCompletionClosureInput = removeCardCompletionClosureInput {
            completion(removeCardCompletionClosureInput)
        }
        return removeCardReturnValue
    }
}

// MARK: - Resets

extension AcquiringSdkMock {
    func fullReset() {
        initPaymentCallsCount = 0
        initPaymentReceivedArguments = nil
        initPaymentReceivedInvocations = []
        initPaymentCompletionClosureInput = nil

        finishAuthorizeCallsCount = 0
        finishAuthorizeReceivedArguments = nil
        finishAuthorizeReceivedInvocations = []
        finishAuthorizeCompletionClosureInput = nil

        chargeCallsCount = 0
        chargeReceivedArguments = nil
        chargeReceivedInvocations = []
        chargeCompletionClosureInput = nil

        getPaymentStateCallsCount = 0
        getPaymentStateReceivedArguments = nil
        getPaymentStateReceivedInvocations = []
        getPaymentStateCompletionClosureInput = nil

        loadSBPBanksCallsCount = 0
        loadSBPBanksReceivedArguments = nil
        loadSBPBanksReceivedInvocations = []
        loadSBPBanksCompletionClosureInput = nil

        getQRCallsCount = 0
        getQRReceivedArguments = nil
        getQRReceivedInvocations = []
        getQRCompletionClosureInput = nil

        getStaticQRCallsCount = 0
        getStaticQRReceivedArguments = nil
        getStaticQRReceivedInvocations = []
        getStaticQRCompletionClosureInput = nil

        getTerminalPayMethodsCallsCount = 0
        getTerminalPayMethodsReceivedArguments = nil
        getTerminalPayMethodsReceivedInvocations = []
        getTerminalPayMethodsCompletionClosureInput = nil

        check3DSVersionCallsCount = 0
        check3DSVersionReceivedArguments = nil
        check3DSVersionReceivedInvocations = []
        check3DSVersionCompletionClosureInput = nil

        confirmation3DSTerminationURLCallsCount = 0

        confirmation3DSTerminationV2URLCallsCount = 0

        confirmation3DSCompleteV2URLCallsCount = 0

        createChecking3DSURLThrowableError = nil
        createChecking3DSURLCallsCount = 0
        createChecking3DSURLReceivedArguments = nil
        createChecking3DSURLReceivedInvocations = []

        createConfirmation3DSRequestThrowableError = nil
        createConfirmation3DSRequestCallsCount = 0
        createConfirmation3DSRequestReceivedArguments = nil
        createConfirmation3DSRequestReceivedInvocations = []

        createConfirmation3DSRequestACSThrowableError = nil
        createConfirmation3DSRequestACSCallsCount = 0
        createConfirmation3DSRequestACSReceivedArguments = nil
        createConfirmation3DSRequestACSReceivedInvocations = []

        submit3DSAuthorizationV2CallsCount = 0
        submit3DSAuthorizationV2ReceivedArguments = nil
        submit3DSAuthorizationV2ReceivedInvocations = []
        submit3DSAuthorizationV2CompletionClosureInput = nil

        getCertsConfigCallsCount = 0
        getCertsConfigReceivedArguments = nil
        getCertsConfigReceivedInvocations = []
        getCertsConfigCompletionClosureInput = nil

        getTinkoffPayLinkCallsCount = 0
        getTinkoffPayLinkReceivedArguments = nil
        getTinkoffPayLinkReceivedInvocations = []
        getTinkoffPayLinkCompletionClosureInput = nil

        getTinkoffPayStatusCallsCount = 0
        getTinkoffPayStatusReceivedArguments = nil
        getTinkoffPayStatusReceivedInvocations = []
        getTinkoffPayStatusCompletionClosureInput = nil

        addCardCallsCount = 0
        addCardReceivedArguments = nil
        addCardReceivedInvocations = []
        addCardCompletionClosureInput = nil

        attachCardCallsCount = 0
        attachCardReceivedArguments = nil
        attachCardReceivedInvocations = []
        attachCardCompletionClosureInput = nil

        getAddCardStateCallsCount = 0
        getAddCardStateReceivedArguments = nil
        getAddCardStateReceivedInvocations = []
        getAddCardStateCompletionClosureInput = nil

        getCardListCallsCount = 0
        getCardListReceivedArguments = nil
        getCardListReceivedInvocations = []
        getCardListCompletionClosureInput = nil

        removeCardCallsCount = 0
        removeCardReceivedArguments = nil
        removeCardReceivedInvocations = []
        removeCardCompletionClosureInput = nil
    }
}
