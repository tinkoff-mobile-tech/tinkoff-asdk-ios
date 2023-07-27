//
//
//  TDSWrapperBuilder.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import ThreeDSWrapper
import TinkoffASDKCore
import UIKit

protocol ITDSWrapperBuilder {
    func build() -> ITDSWrapper
}

final class TDSWrapperBuilder: ITDSWrapperBuilder {

    private let env: AcquiringSdkEnvironment
    private let language: AcquiringSdkLanguage?

    init(
        env: AcquiringSdkEnvironment,
        language: AcquiringSdkLanguage?
    ) {
        self.env = env
        self.language = language
    }

    func build() -> ITDSWrapper {
        let locale: Locale

        switch language {
        case .ru:
            locale = Locale(identifier: .russian)
        case .en:
            locale = Locale(identifier: .english)
        default:
            locale = Locale(identifier: .russian)
        }

        let sdkConfiguration = TDSWrapper.SDKConfiguration(
            uiCustomization: buildUICustomization(),
            locale: locale
        )

        let environment: ThreeDSWrapper.TDSWrapper.Environment = {
            switch env {
            case .prod, .custom: return .production
            case .preProd: return .production
            case .test, .uitest: return .test
            }
        }()

        return TDSWrapper(
            sdkConfiguration: sdkConfiguration,
            wrapperConfiguration: TDSWrapper.WrapperConfiguration(environment: environment)
        )
    }

    private func buildUICustomization() -> ThreeDSWrapper.UiCustomization {
        let customization = ThreeDSWrapper.UiCustomization()

        let regularFont = UIFont.systemFont(ofSize: .regularFontSize)
        let semiboldFont = UIFont.systemFont(ofSize: .regularFontSize, weight: .semibold)

        let labelCustomization = ThreeDSWrapper.LabelCustomization()
        labelCustomization.setHeadingTextColor(ASDKColors.Text.primary.color)
        labelCustomization.setHeadingTextFontName(semiboldFont.fontName)
        labelCustomization.setHeadingTextFontSize(.headingTextFontSize)
        labelCustomization.setTextColor(ASDKColors.Text.primary.color)
        labelCustomization.setTextFontName(regularFont.fontName)
        labelCustomization.setTextFontSize(Int(regularFont.pointSize))
        customization.setLabelCustomization(labelCustomization)

        let buttonCustomization = ThreeDSWrapper.ButtonCustomization()
        buttonCustomization.setBackgroundColor(ASDKColors.Foreground.brandTinkoffAccent)
        buttonCustomization.setCornerRadius(.buttonCornerRadius)
        buttonCustomization.setTextColor(ASDKColors.Text.primary.color)
        buttonCustomization.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomization.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomization, buttonType: .SUBMIT)

        let buttonCustomizationResend = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationResend.setBackgroundColor(ASDKColors.Foreground.brandTinkoffAccent)
        buttonCustomizationResend.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationResend.setTextColor(ASDKColors.Text.primary.color)
        buttonCustomizationResend.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationResend.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationResend, buttonType: .RESEND)

        let buttonCustomizationVerify = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationVerify.setBackgroundColor(ASDKColors.Foreground.brandTinkoffAccent)
        buttonCustomizationVerify.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationVerify.setTextColor(ASDKColors.Text.primary.color)
        buttonCustomizationVerify.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationVerify.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationVerify, buttonType: .VERIFY)

        let buttonCustomizationContinue = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationContinue.setBackgroundColor(ASDKColors.Foreground.brandTinkoffAccent)
        buttonCustomizationContinue.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationContinue.setTextColor(ASDKColors.Text.primary.color)
        buttonCustomizationContinue.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationContinue.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationContinue, buttonType: .CONTINUE)

        let buttonCustomizationNext = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationNext.setBackgroundColor(ASDKColors.Foreground.brandTinkoffAccent)
        buttonCustomizationNext.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationNext.setTextColor(ASDKColors.Text.primary.color)
        buttonCustomizationNext.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationNext.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationNext, buttonType: .NEXT)

        let buttonCustomizationCancel = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationCancel.setBackgroundColor(ASDKColors.Foreground.brandTinkoffAccent)
        buttonCustomizationCancel.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationCancel.setTextColor(ASDKColors.Text.primary.color)
        buttonCustomizationCancel.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationCancel.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationCancel, buttonType: .CANCEL)

        let textBoxCustomization = ThreeDSWrapper.TextBoxCustomization()
        textBoxCustomization.setBorderWidth(1)
        textBoxCustomization.setBorderColor(ASDKColors.Background.separator.color)
        textBoxCustomization.setCornerRadius(.buttonCornerRadius)
        textBoxCustomization.setTextColor(ASDKColors.Text.primary.color)
        textBoxCustomization.setTextFontSize(Int(regularFont.pointSize))
        textBoxCustomization.setTextFontName(regularFont.fontName)
        customization.setTextBoxCustomization(textBoxCustomization)

        let toolbarCustomization = ThreeDSWrapper.ToolbarCustomization()
        toolbarCustomization.setBackgroundColor(ASDKColors.Background.base.color)
        toolbarCustomization.setTextColor(ASDKColors.Text.primary.color)
        toolbarCustomization.setTextFontSize(Int(semiboldFont.pointSize))
        toolbarCustomization.setTextFontName(semiboldFont.fontName)
        toolbarCustomization.setHeaderText(Loc.TinkoffAcquiring.Threeds.acceptAuth)
        toolbarCustomization.setButtonText(Loc.TinkoffAcquiring.Threeds.cancelAuth)

        customization.setToolbarCusomization(toolbarCustomization)

        return customization
    }
}

// MARK: - Locale identifiers

private extension String {
    static let russian = "ru_RU"
    static let english = "en_US"
}

// MARK: - Constants

private extension Int {
    static let buttonCornerRadius = 16
    static let headingTextFontSize = 30
}

private extension CGFloat {
    static let regularFontSize = 17 as CGFloat
}
