//
//  ITextAndImageHeaderViewPresenterAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

protocol ITextAndImageHeaderViewPresenterAssembly {
    func build(title: String, imageAsset: ImageAsset?) -> any ITextAndImageHeaderViewOutput
}

extension ITextAndImageHeaderViewPresenterAssembly {
    func build(title: String) -> any ITextAndImageHeaderViewOutput {
        build(title: title, imageAsset: nil)
    }
}
