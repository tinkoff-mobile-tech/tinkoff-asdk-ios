//
//  PaymentActivityViewState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 15.12.2022.
//

import Foundation
import UIKit

enum PaymentActivityViewState: Equatable {
    struct Processed: Equatable {
        let image: UIImage
        let title: String
        let description: String?
        let primaryButtonTitle: String

        init(
            image: UIImage,
            title: String,
            description: String? = nil,
            primaryButtonTitle: String
        ) {
            self.image = image
            self.title = title
            self.description = description
            self.primaryButtonTitle = primaryButtonTitle
        }
    }

    struct Processing: Equatable {
        let title: String
        let description: String
    }

    case idle
    case processing(Processing)
    case processed(Processed)
}
