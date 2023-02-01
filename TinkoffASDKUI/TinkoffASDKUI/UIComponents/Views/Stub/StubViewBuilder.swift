//
//  StubViewBuilder.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 13.12.2022.
//

import UIKit

protocol IStubViewBuilder {
    /// Builds a properly configured Info Cover View
    /// with a proper frame (height equals to contentHeight)
    func buildStubView(input: BaseStubViewBuilder.InputData) -> StubView

    func buildFrom(coverMode: StubMode) -> StubView
}

final class BaseStubViewBuilder: IStubViewBuilder {

    func buildStubView(input: InputData) -> StubView {
        let config = buildConfig(inputData: input)
        let infoView = StubView(layout: StubView.Layout())
        infoView.configure(with: config)
        infoView.getContentHeight()
        return infoView
    }

    func buildFrom(coverMode: StubMode) -> StubView {
        buildStubView(input: coverMode.convertToInfoInputData())
    }

    private func buildConfig(inputData: InputData) -> StubView.Configuration {
        let config = StubView.Configuration(
            icon: UIImageView.Configuration(image: inputData.icon, contentMode: .scaleAspectFit, clipsToBounds: true),
            title: UILabel.Configuration(
                content: .plain(
                    text: inputData.title,
                    style: .headingS()
                        .set(alignment: .center)
                        .set(textColor: ASDKColors.Text.primary.color)
                        .set(numberOfLines: 2)
                )
            ),
            subtitle: UILabel.Configuration(
                content: .plain(
                    text: inputData.subtitle,
                    style: .bodyM()
                        .set(alignment: .center)
                        .set(textColor: ASDKColors.Text.secondary.color)
                        .set(numberOfLines: 2)
                )
            ),
            button: Button.DeprecatedConfiguration(
                data: Button.Data(
                    text: .basic(normal: inputData.buttonTitle, highlighted: nil, disabled: nil),
                    onTapAction: inputData.buttonAction
                ),
                style: .secondary
                    .set(contentEdgeInsets: UIEdgeInsets(vertical: 13, horizontal: 18))
                    .set(font: UILabel.Style.bodyM().font)
                    .set(cornerRadius: 12)
            )
        )

        return config
    }
}

extension BaseStubViewBuilder {

    struct InputData {
        let icon: UIImage
        let title: String
        let subtitle: String
        let buttonTitle: String
        let buttonAction: () -> Void
    }
}
