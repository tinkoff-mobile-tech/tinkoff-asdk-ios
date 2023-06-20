//
//  TextAndImageHeaderViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

final class TextAndImageHeaderViewPresenterAssembly: ITextAndImageHeaderViewPresenterAssembly {
    // MARK: ITextAndImageHeaderViewPresenter

    func build(title: String, imageAsset: ImageAsset?) -> any ITextAndImageHeaderViewOutput {
        TextAndImageHeaderViewPresenter(title: title, imageAsset: imageAsset)
    }
}
