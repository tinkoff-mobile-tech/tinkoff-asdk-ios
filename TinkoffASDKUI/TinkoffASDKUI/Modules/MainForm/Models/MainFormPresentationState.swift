//
//  MainFormPresentationState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 21.03.2023.
//

import Foundation
import TinkoffASDKCore

enum MainFormPresentationState {
    case loading
    case payMethodsPresenting
    case tinkoffPayProcessing(Cancellable)
    case paid
    case recoverableFailure
    case unrecoverableFailure
}
