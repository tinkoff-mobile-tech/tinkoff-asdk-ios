//
//  TextAndImageHeaderViewPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

final class TextAndImageHeaderViewPresenter: ITextAndImageHeaderViewOutput {
    // MARK: ITextHeaderViewOutput Properties

    weak var view: ITextAndImageHeaderViewInput? {
        didSet { setupView() }
    }

    // MARK: Dependencies

    private let title: String
    private let imageAsset: ImageAsset?

    init(title: String, imageAsset: ImageAsset?) {
        self.title = title
        self.imageAsset = imageAsset
    }

    // MARK: ITextHeaderViewOutput

    func copy() -> any ITextAndImageHeaderViewOutput {
        TextAndImageHeaderViewPresenter(title: title, imageAsset: imageAsset)
    }

    // MARK: View Reloading

    private func setupView() {
        view?.set(title: title)
        view?.set(image: imageAsset?.image)
    }
}

// MARK: - Equatable

extension TextAndImageHeaderViewPresenter {
    static func == (lhs: TextAndImageHeaderViewPresenter, rhs: TextAndImageHeaderViewPresenter) -> Bool {
        lhs.title == rhs.title && lhs.imageAsset == rhs.imageAsset
    }
}
