//
//  TextHeaderViewPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

final class TextHeaderViewPresenter: ITextHeaderViewOutput {
    // MARK: ITextHeaderViewOutput Properties

    weak var view: ITextHeaderViewInput? {
        didSet { setupView() }
    }

    // MARK: Dependencies

    private let title: String

    init(title: String) {
        self.title = title
    }

    // MARK: View Reloading

    private func setupView() {
        view?.set(title: title)
    }
}
