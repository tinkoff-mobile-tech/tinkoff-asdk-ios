//
//  CommonSheetState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 15.12.2022.
//

import Foundation
import UIKit

struct CommonSheetState {
    enum Status {
        case processing
        case succeeded
        case failed
    }

    let status: Status
    let title: String
    let description: String?
    let primaryButtonTitle: String?
    let secondaryButtonTitle: String?
    let dismissionAllowed: Bool

    init(
        status: Status,
        title: String,
        description: String? = nil,
        primaryButtonTitle: String? = nil,
        secondaryButtonTitle: String? = nil,
        dismissionAllowed: Bool = true
    ) {
        self.status = status
        self.title = title
        self.description = description
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.dismissionAllowed = dismissionAllowed
    }
}
