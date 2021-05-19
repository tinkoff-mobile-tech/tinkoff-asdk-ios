//
//
//  SBPBankCell.swift
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


import UIKit

final class SBPBankCell: UITableViewCell {
    
    let bankTitleLabel = UILabel()
    let logoImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SBPBankCell {
    func setup() {
        contentView.addSubview(bankTitleLabel)
        contentView.addSubview(logoImageView)
        
        selectionStyle = .none
        
        bankTitleLabel.numberOfLines = 1
        
        setupConstraints()
    }
    
    func setupConstraints() {
        bankTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageView.heightAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .logoImageLeftOffset),
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .logoImageVerticalOffset),
            logoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.logoImageVerticalOffset),
            
            bankTitleLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            bankTitleLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: .titleLeftInset),
            bankTitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
}

private extension CGFloat {
    static let logoImageSide: CGFloat = 40
    static let logoImageVerticalOffset: CGFloat = 8
    static let logoImageLeftOffset: CGFloat = 16
    static let titleLeftInset: CGFloat = 16
}
