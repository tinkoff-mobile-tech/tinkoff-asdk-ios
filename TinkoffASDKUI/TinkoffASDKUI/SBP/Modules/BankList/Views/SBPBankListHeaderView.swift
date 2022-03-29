//
//
//  SBPBankListHeaderView.swift
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

final class SBPBankListHeaderView: UIView {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SBPBankListHeaderView {
    func setup() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.asdk.n3

        titleLabel.numberOfLines = 1
        subtitleLabel.numberOfLines = 0
        
        setupConstraints()
    }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: .titleTopOffset),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: .contentSideOffset),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -.contentSideOffset),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .subtitleTopOffset),
            subtitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: .contentSideOffset),
            subtitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -.contentSideOffset),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.subtitleBottomOffset)
        ])
    }
}

private extension CGFloat {
    static let titleTopOffset: CGFloat = 12
    static let subtitleTopOffset: CGFloat = 4
    static let subtitleBottomOffset: CGFloat = 12
    static let contentSideOffset: CGFloat = 16
}
