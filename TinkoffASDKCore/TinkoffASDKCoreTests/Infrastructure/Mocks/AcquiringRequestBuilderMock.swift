//
//  AcquiringRequestBuilderMock.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 26.07.2023.
//

import Foundation
@testable import TinkoffASDKCore

final class AcquiringRequestBuilderMock: IAcquiringRequestBuilder {

    // MARK: - initRequest

    typealias InitRequestArguments = PaymentInitData

    var initRequestCallsCount = 0
    var initRequestReceivedArguments: InitRequestArguments?
    var initRequestReceivedInvocations: [InitRequestArguments?] = []
    var initRequestReturnValue: AcquiringRequest!

    func initRequest(data: PaymentInitData) -> AcquiringRequest {
        initRequestCallsCount += 1
        let arguments = data
        initRequestReceivedArguments = arguments
        initRequestReceivedInvocations.append(arguments)
        return initRequestReturnValue
    }

    // MARK: - finishAuthorize

    typealias FinishAuthorizeArguments = FinishAuthorizeData

    var finishAuthorizeCallsCount = 0
    var finishAuthorizeReceivedArguments: FinishAuthorizeArguments?
    var finishAuthorizeReceivedInvocations: [FinishAuthorizeArguments?] = []
    var finishAuthorizeReturnValue: AcquiringRequest!

    func finishAuthorize(data: FinishAuthorizeData) -> AcquiringRequest {
        finishAuthorizeCallsCount += 1
        let arguments = data
        finishAuthorizeReceivedArguments = arguments
        finishAuthorizeReceivedInvocations.append(arguments)
        return finishAuthorizeReturnValue
    }

    // MARK: - check3DSVersion

    typealias Check3DSVersionArguments = Check3DSVersionData

    var check3DSVersionCallsCount = 0
    var check3DSVersionReceivedArguments: Check3DSVersionArguments?
    var check3DSVersionReceivedInvocations: [Check3DSVersionArguments?] = []
    var check3DSVersionReturnValue: AcquiringRequest!

    func check3DSVersion(data: Check3DSVersionData) -> AcquiringRequest {
        check3DSVersionCallsCount += 1
        let arguments = data
        check3DSVersionReceivedArguments = arguments
        check3DSVersionReceivedInvocations.append(arguments)
        return check3DSVersionReturnValue
    }

    // MARK: - submit3DSAuthorizationV2

    typealias Submit3DSAuthorizationV2Arguments = CresData

    var submit3DSAuthorizationV2CallsCount = 0
    var submit3DSAuthorizationV2ReceivedArguments: Submit3DSAuthorizationV2Arguments?
    var submit3DSAuthorizationV2ReceivedInvocations: [Submit3DSAuthorizationV2Arguments?] = []
    var submit3DSAuthorizationV2ReturnValue: AcquiringRequest!

    func submit3DSAuthorizationV2(data: CresData) -> AcquiringRequest {
        submit3DSAuthorizationV2CallsCount += 1
        let arguments = data
        submit3DSAuthorizationV2ReceivedArguments = arguments
        submit3DSAuthorizationV2ReceivedInvocations.append(arguments)
        return submit3DSAuthorizationV2ReturnValue
    }

    // MARK: - getPaymentState

    typealias GetPaymentStateArguments = GetPaymentStateData

    var getPaymentStateCallsCount = 0
    var getPaymentStateReceivedArguments: GetPaymentStateArguments?
    var getPaymentStateReceivedInvocations: [GetPaymentStateArguments?] = []
    var getPaymentStateReturnValue: AcquiringRequest!

    func getPaymentState(data: GetPaymentStateData) -> AcquiringRequest {
        getPaymentStateCallsCount += 1
        let arguments = data
        getPaymentStateReceivedArguments = arguments
        getPaymentStateReceivedInvocations.append(arguments)
        return getPaymentStateReturnValue
    }

    // MARK: - charge

    typealias ChargeArguments = ChargeData

    var chargeCallsCount = 0
    var chargeReceivedArguments: ChargeArguments?
    var chargeReceivedInvocations: [ChargeArguments?] = []
    var chargeReturnValue: AcquiringRequest!

    func charge(data: ChargeData) -> AcquiringRequest {
        chargeCallsCount += 1
        let arguments = data
        chargeReceivedArguments = arguments
        chargeReceivedInvocations.append(arguments)
        return chargeReturnValue
    }

    // MARK: - getCardList

    typealias GetCardListArguments = GetCardListData

    var getCardListCallsCount = 0
    var getCardListReceivedArguments: GetCardListArguments?
    var getCardListReceivedInvocations: [GetCardListArguments?] = []
    var getCardListReturnValue: AcquiringRequest!

    func getCardList(data: GetCardListData) -> AcquiringRequest {
        getCardListCallsCount += 1
        let arguments = data
        getCardListReceivedArguments = arguments
        getCardListReceivedInvocations.append(arguments)
        return getCardListReturnValue
    }

    // MARK: - addCard

    typealias AddCardArguments = AddCardData

    var addCardCallsCount = 0
    var addCardReceivedArguments: AddCardArguments?
    var addCardReceivedInvocations: [AddCardArguments?] = []
    var addCardReturnValue: AcquiringRequest!

    func addCard(data: AddCardData) -> AcquiringRequest {
        addCardCallsCount += 1
        let arguments = data
        addCardReceivedArguments = arguments
        addCardReceivedInvocations.append(arguments)
        return addCardReturnValue
    }

    // MARK: - attachCard

    typealias AttachCardArguments = AttachCardData

    var attachCardCallsCount = 0
    var attachCardReceivedArguments: AttachCardArguments?
    var attachCardReceivedInvocations: [AttachCardArguments?] = []
    var attachCardReturnValue: AcquiringRequest!

    func attachCard(data: AttachCardData) -> AcquiringRequest {
        attachCardCallsCount += 1
        let arguments = data
        attachCardReceivedArguments = arguments
        attachCardReceivedInvocations.append(arguments)
        return attachCardReturnValue
    }

    // MARK: - getAddCardState

    typealias GetAddCardStateArguments = GetAddCardStateData

    var getAddCardStateCallsCount = 0
    var getAddCardStateReceivedArguments: GetAddCardStateArguments?
    var getAddCardStateReceivedInvocations: [GetAddCardStateArguments?] = []
    var getAddCardStateReturnValue: AcquiringRequest!

    func getAddCardState(data: GetAddCardStateData) -> AcquiringRequest {
        getAddCardStateCallsCount += 1
        let arguments = data
        getAddCardStateReceivedArguments = arguments
        getAddCardStateReceivedInvocations.append(arguments)
        return getAddCardStateReturnValue
    }

    // MARK: - submitRandomAmount

    typealias SubmitRandomAmountArguments = SubmitRandomAmountData

    var submitRandomAmountCallsCount = 0
    var submitRandomAmountReceivedArguments: SubmitRandomAmountArguments?
    var submitRandomAmountReceivedInvocations: [SubmitRandomAmountArguments?] = []
    var submitRandomAmountReturnValue: AcquiringRequest!

    func submitRandomAmount(data: SubmitRandomAmountData) -> AcquiringRequest {
        submitRandomAmountCallsCount += 1
        let arguments = data
        submitRandomAmountReceivedArguments = arguments
        submitRandomAmountReceivedInvocations.append(arguments)
        return submitRandomAmountReturnValue
    }

    // MARK: - removeCard

    typealias RemoveCardArguments = RemoveCardData

    var removeCardCallsCount = 0
    var removeCardReceivedArguments: RemoveCardArguments?
    var removeCardReceivedInvocations: [RemoveCardArguments?] = []
    var removeCardReturnValue: AcquiringRequest!

    func removeCard(data: RemoveCardData) -> AcquiringRequest {
        removeCardCallsCount += 1
        let arguments = data
        removeCardReceivedArguments = arguments
        removeCardReceivedInvocations.append(arguments)
        return removeCardReturnValue
    }

    // MARK: - getQR

    typealias GetQRArguments = GetQRData

    var getQRCallsCount = 0
    var getQRReceivedArguments: GetQRArguments?
    var getQRReceivedInvocations: [GetQRArguments?] = []
    var getQRReturnValue: AcquiringRequest!

    func getQR(data: GetQRData) -> AcquiringRequest {
        getQRCallsCount += 1
        let arguments = data
        getQRReceivedArguments = arguments
        getQRReceivedInvocations.append(arguments)
        return getQRReturnValue
    }

    // MARK: - getStaticQR

    typealias GetStaticQRArguments = GetQRDataType

    var getStaticQRCallsCount = 0
    var getStaticQRReceivedArguments: GetStaticQRArguments?
    var getStaticQRReceivedInvocations: [GetStaticQRArguments?] = []
    var getStaticQRReturnValue: AcquiringRequest!

    func getStaticQR(data: GetQRDataType) -> AcquiringRequest {
        getStaticQRCallsCount += 1
        let arguments = data
        getStaticQRReceivedArguments = arguments
        getStaticQRReceivedInvocations.append(arguments)
        return getStaticQRReturnValue
    }

    // MARK: - getTinkoffPayStatus

    var getTinkoffPayStatusCallsCount = 0
    var getTinkoffPayStatusReturnValue: AcquiringRequest!

    func getTinkoffPayStatus() -> AcquiringRequest {
        getTinkoffPayStatusCallsCount += 1
        return getTinkoffPayStatusReturnValue
    }

    // MARK: - getTinkoffPayLink

    typealias GetTinkoffPayLinkArguments = GetTinkoffLinkData

    var getTinkoffPayLinkCallsCount = 0
    var getTinkoffPayLinkReceivedArguments: GetTinkoffPayLinkArguments?
    var getTinkoffPayLinkReceivedInvocations: [GetTinkoffPayLinkArguments?] = []
    var getTinkoffPayLinkReturnValue: AcquiringRequest!

    func getTinkoffPayLink(data: GetTinkoffLinkData) -> AcquiringRequest {
        getTinkoffPayLinkCallsCount += 1
        let arguments = data
        getTinkoffPayLinkReceivedArguments = arguments
        getTinkoffPayLinkReceivedInvocations.append(arguments)
        return getTinkoffPayLinkReturnValue
    }

    // MARK: - getTerminalPayMethods

    var getTerminalPayMethodsCallsCount = 0
    var getTerminalPayMethodsReturnValue: AcquiringRequest!

    func getTerminalPayMethods() -> AcquiringRequest {
        getTerminalPayMethodsCallsCount += 1
        return getTerminalPayMethodsReturnValue
    }
}

// MARK: - Resets

extension AcquiringRequestBuilderMock {
    func fullReset() {
        initRequestCallsCount = 0
        initRequestReceivedArguments = nil
        initRequestReceivedInvocations = []

        finishAuthorizeCallsCount = 0
        finishAuthorizeReceivedArguments = nil
        finishAuthorizeReceivedInvocations = []

        check3DSVersionCallsCount = 0
        check3DSVersionReceivedArguments = nil
        check3DSVersionReceivedInvocations = []

        submit3DSAuthorizationV2CallsCount = 0
        submit3DSAuthorizationV2ReceivedArguments = nil
        submit3DSAuthorizationV2ReceivedInvocations = []

        getPaymentStateCallsCount = 0
        getPaymentStateReceivedArguments = nil
        getPaymentStateReceivedInvocations = []

        chargeCallsCount = 0
        chargeReceivedArguments = nil
        chargeReceivedInvocations = []

        getCardListCallsCount = 0
        getCardListReceivedArguments = nil
        getCardListReceivedInvocations = []

        addCardCallsCount = 0
        addCardReceivedArguments = nil
        addCardReceivedInvocations = []

        attachCardCallsCount = 0
        attachCardReceivedArguments = nil
        attachCardReceivedInvocations = []

        getAddCardStateCallsCount = 0
        getAddCardStateReceivedArguments = nil
        getAddCardStateReceivedInvocations = []

        submitRandomAmountCallsCount = 0
        submitRandomAmountReceivedArguments = nil
        submitRandomAmountReceivedInvocations = []

        removeCardCallsCount = 0
        removeCardReceivedArguments = nil
        removeCardReceivedInvocations = []

        getQRCallsCount = 0
        getQRReceivedArguments = nil
        getQRReceivedInvocations = []

        getStaticQRCallsCount = 0
        getStaticQRReceivedArguments = nil
        getStaticQRReceivedInvocations = []

        getTinkoffPayStatusCallsCount = 0

        getTinkoffPayLinkCallsCount = 0
        getTinkoffPayLinkReceivedArguments = nil
        getTinkoffPayLinkReceivedInvocations = []

        getTerminalPayMethodsCallsCount = 0
    }
}
