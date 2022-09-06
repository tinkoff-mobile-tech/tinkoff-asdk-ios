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

protocol ITDSWrapperBuilder {
    func build() -> TDSWrapper
}

final class TDSWrapperBuilder: ITDSWrapperBuilder {
    
    private let env: AcquiringSdkEnvironment
    private let language: AcquiringSdkLanguage?
    
    init(env: AcquiringSdkEnvironment,
         language: AcquiringSdkLanguage?) {
        self.env = env
        self.language = language
    }
    
    
    func build() -> TDSWrapper {
        let locale: Locale

        switch language {
        case .ru:
            locale = Locale(identifier: .russian)
        case .en:
            locale = Locale(identifier: .english)
        default:
            locale = Locale(identifier: .russian)
        }
        
        let sdkConfiguration = TDSWrapper.SDKConfiguration(uiCustomization: buildUICustomization(),
                                                           locale: locale)
        return TDSWrapper(sdkConfiguration: sdkConfiguration,
                          wrapperConfiguration: .init(environment: env == .test ? .test : .production))
    }
    
    private func buildUICustomization() -> ThreeDSWrapper.UiCustomization {
        let customization = ThreeDSWrapper.UiCustomization()
        
        let regularFont = UIFont.systemFont(ofSize: .regularFontSize)
        let semiboldFont = UIFont.systemFont(ofSize: .regularFontSize, weight: .semibold)
        
        let labelCustomization = ThreeDSWrapper.LabelCustomization()
        labelCustomization.setHeadingTextColor(UIColor.asdk.dynamic.text.primary.hex)
        labelCustomization.setHeadingTextFontName(semiboldFont.fontName)
        labelCustomization.setHeadingTextFontSize(.headingTextFontSize)
        labelCustomization.setTextColor(UIColor.asdk.dynamic.text.primary.hex)
        labelCustomization.setTextFontName(regularFont.fontName)
        labelCustomization.setTextFontSize(Int(regularFont.pointSize))
        customization.setLabelCustomization(labelCustomization)
        
        let buttonCustomization: ThreeDSWrapper.ButtonCustomization = ThreeDSWrapper.ButtonCustomization()
        buttonCustomization.setBackgroundColor(UIColor.asdk.yellow.hex)
        buttonCustomization.setCornerRadius(.buttonCornerRadius)
        buttonCustomization.setTextColor(UIColor.asdk.dynamic.text.primary.hex)
        buttonCustomization.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomization.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomization, buttonType: .SUBMIT)
        
        let buttonCustomizationResend: ThreeDSWrapper.ButtonCustomization = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationResend.setBackgroundColor(UIColor.asdk.yellow.hex)
        buttonCustomizationResend.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationResend.setTextColor(UIColor.asdk.dynamic.text.primary.hex)
        buttonCustomizationResend.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationResend.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationResend, buttonType: .RESEND)
        
        let buttonCustomizationVerify: ThreeDSWrapper.ButtonCustomization = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationVerify.setBackgroundColor(UIColor.asdk.yellow.hex)
        buttonCustomizationVerify.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationVerify.setTextColor(UIColor.asdk.dynamic.text.primary.hex)
        buttonCustomizationVerify.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationVerify.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationVerify, buttonType: .VERIFY)
        
        let buttonCustomizationContinue: ThreeDSWrapper.ButtonCustomization = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationContinue.setBackgroundColor(UIColor.asdk.yellow.hex)
        buttonCustomizationContinue.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationContinue.setTextColor(UIColor.asdk.dynamic.text.primary.hex)
        buttonCustomizationContinue.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationContinue.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationContinue, buttonType: .CONTINUE)
        
        let buttonCustomizationNext: ThreeDSWrapper.ButtonCustomization = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationNext.setBackgroundColor(UIColor.asdk.yellow.hex)
        buttonCustomizationNext.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationNext.setTextColor(UIColor.asdk.dynamic.text.primary.hex)
        buttonCustomizationNext.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationNext.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationNext, buttonType: .NEXT)
        
        let buttonCustomizationCancel: ThreeDSWrapper.ButtonCustomization = ThreeDSWrapper.ButtonCustomization()
        buttonCustomizationCancel.setBackgroundColor(UIColor.asdk.yellow.hex)
        buttonCustomizationCancel.setCornerRadius(.buttonCornerRadius)
        buttonCustomizationCancel.setTextColor(UIColor.asdk.dynamic.text.primary.hex)
        buttonCustomizationCancel.setTextFontSize(Int(regularFont.pointSize))
        buttonCustomizationCancel.setTextFontName(regularFont.fontName)
        customization.setButtonCustomization(buttonCustomization: buttonCustomizationCancel, buttonType: .CANCEL)
        
        let textBoxCustomization = ThreeDSWrapper.TextBoxCustomization()
        textBoxCustomization.setBorderWidth(1)
        textBoxCustomization.setBorderColor(UIColor.asdk.dynamic.background.separator.hex)
        textBoxCustomization.setCornerRadius(.buttonCornerRadius)
        textBoxCustomization.setTextColor(UIColor.asdk.dynamic.text.primary.hex)
        textBoxCustomization.setTextFontSize(Int(regularFont.pointSize))
        textBoxCustomization.setTextFontName(regularFont.fontName)
        customization.setTextBoxCustomization(textBoxCustomization)
        
        let toolbarCustomization = ThreeDSWrapper.ToolbarCustomization()
        toolbarCustomization.setBackgroundColor(UIColor.asdk.dynamic.background.base.hex)
        toolbarCustomization.setTextColor(UIColor.asdk.dynamic.text.primary.hex)
        toolbarCustomization.setTextFontSize(Int(semiboldFont.pointSize))
        toolbarCustomization.setTextFontName(semiboldFont.fontName)
        toolbarCustomization.setHeaderText(L10n.TinkoffAcquiring.Threeds.acceptAuth)
        toolbarCustomization.setButtonText(L10n.TinkoffAcquiring.Threeds.cancelAuth)

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
