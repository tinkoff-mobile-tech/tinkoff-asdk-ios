//
//  CommonSheetState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 15.12.2022.
//

import Foundation
import UIKit

struct CommonSheetState: Equatable {
    enum Status {
        case processing
        case succeeded
        case failed
    }

    let status: Status
    let title: String?
    let description: String?
    let primaryButtonTitle: String?
    let secondaryButtonTitle: String?

    init(
        status: Status,
        title: String? = nil,
        description: String? = nil,
        primaryButtonTitle: String? = nil,
        secondaryButtonTitle: String? = nil
    ) {
        self.status = status
        self.title = title
        self.description = description
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
    }
}
