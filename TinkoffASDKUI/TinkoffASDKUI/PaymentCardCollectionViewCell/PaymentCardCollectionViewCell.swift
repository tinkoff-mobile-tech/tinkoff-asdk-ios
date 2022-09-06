//
//  PaymentCardCollectionViewCell.swift
//  TinkoffASDKUI
//
//  Copyright (c) 2020 Tinkoff Bank
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

import UIKit

protocol InputCardCVCRequisitesPresenterProtocol: AnyObject {
    var textFieldCardCVC: UITextFieldCardRequisites! { get }
}

class PaymentCardCollectionViewCell: UICollectionViewCell, InputCardCVCRequisitesPresenterProtocol {
    @IBOutlet var viewBorder: UIView!
    @IBOutlet var imageViewLogo: UIImageView!
    @IBOutlet var labelCardName: UILabel!
    @IBOutlet var labelCardExpData: UILabel!
    @IBOutlet var textFieldCardCVC: UITextFieldCardRequisites!
    @IBOutlet private var viewSeparator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        viewBorder.layer.cornerRadius = 12
        viewBorder.layer.shadowColor = labelCardName.textColor.cgColor
        viewBorder.layer.shadowOpacity = 0.1
        viewBorder.layer.shadowOffset = .zero
        viewBorder.layer.shadowRadius = 8

        imageViewLogo.image = nil
        imageViewLogo.isHidden = true

        labelCardName.text = nil
        labelCardExpData.text = nil

        textFieldCardCVC.placeholder = "CVC"
        textFieldCardCVC.text = nil
        textFieldCardCVC.isSecureTextEntry = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageViewLogo.image = nil
        imageViewLogo.isHidden = true

        labelCardName.text = nil
        labelCardExpData.text = nil

        textFieldCardCVC.text = nil
    }
}

extension PaymentCardCollectionViewCell: InputViewStatus {
    func setStatus(_ value: InputFieldTableViewCellStatus, statusText _: String?) {
        switch value {
        case .error:
            textFieldCardCVC.textColor = colorError
            viewSeparator.backgroundColor = colorError

        case .normal:
            textFieldCardCVC.textColor = colorNormal
            viewSeparator.backgroundColor = .clear

        case .disable:
            textFieldCardCVC.textColor = colorDisable
            viewSeparator.backgroundColor = .clear
        }
    }
}
