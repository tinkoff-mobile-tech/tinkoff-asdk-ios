//
//  IEmailViewPresenterOutput.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 27.01.2023.
//

protocol IEmailViewPresenterOutput: AnyObject {
    func emailTextFieldDidBeginEditing(_ presenter: EmailViewPresenter)
    func emailTextField(_ presenter: EmailViewPresenter, didChangeEmail email: String, isValid: Bool)
    func emailTextFieldDidEndEditing(_ presenter: EmailViewPresenter)
    func emailTextFieldDidPressReturn(_ presenter: EmailViewPresenter)
}

extension IEmailViewPresenterOutput {
    func emailTextFieldDidBeginEditing(_ presenter: EmailViewPresenter) {}
    func emailTextFieldDidEndEditing(_ presenter: EmailViewPresenter) {}
    func emailTextFieldDidPressReturn(_ presenter: EmailViewPresenter) {}
}
