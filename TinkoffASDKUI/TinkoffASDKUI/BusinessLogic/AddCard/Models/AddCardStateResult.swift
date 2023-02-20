//
//  AddCardStateResult.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

public enum AddCardStateResult {
    case succeded(GetAddCardStatePayload)
    case failed(Error)
    case cancelled
}
