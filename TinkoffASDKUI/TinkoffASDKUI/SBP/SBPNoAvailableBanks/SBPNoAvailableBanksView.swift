//
//
//  SBPNoAvailableBanksView.swift
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

final class SBPNoAvailableBanksView: UIView {
    
    // MARK: - Style
    
    struct Style {
        let confirmButtonStyle: ButtonStyle
    }
    
    private let style: Style
    
    let informationButton = BigButton(type: .system)
    let confirmButton = BigButton(type: .system)
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let imageView = UIImageView()
    
    private let bottomStackView = UIStackView()
    private let topContainerView = UIView()
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SBPNoAvailableBanksView {
    func setup() {
        addSubview(bottomStackView)
        addSubview(topContainerView)
        
        let backgroundColor: UIColor
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        self.backgroundColor = backgroundColor
         
        topContainerView.addSubview(imageView)
        
        bottomStackView.addArrangedSubview(titleLabel)
        bottomStackView.addArrangedSubview(descriptionLabel)
        bottomStackView.addArrangedSubview(confirmButton)
        bottomStackView.addArrangedSubview(informationButton)
        
        bottomStackView.setCustomSpacing(.titleBottomOffset, after: titleLabel)
        bottomStackView.setCustomSpacing(.descriptionBottomOffset, after: descriptionLabel)
        bottomStackView.setCustomSpacing(.interButtonSpace, after: confirmButton)
        bottomStackView.setCustomSpacing(.bottomButtonsOffset, after: informationButton)
                
        bottomStackView.axis = .vertical
                
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: .titleFontSize,
                                      weight: .medium)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: .descriptionFontSize,
                                            weight: .regular)
        descriptionLabel.textColor = UIColor.asdk.n3
        
        confirmButton.titleLabel?.font = .systemFont(ofSize: .buttonTitleFontSize, weight: .regular)
        confirmButton.backgroundColor = style.confirmButtonStyle.backgroundColor
        confirmButton.setTitleColor(style.confirmButtonStyle.titleColor, for: .normal)
        
        informationButton.titleLabel?.font = .systemFont(ofSize: .buttonTitleFontSize,
                                                         weight: .regular)
        informationButton.backgroundColor = .clear
        informationButton.setTitleColor(UIColor.asdk.n8, for: .normal)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomStackView.widthAnchor.constraint(equalToConstant: .bottomContentWidth),
            
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.heightAnchor.constraint(equalToConstant: .imageSide),
            imageView.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            
            topContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topContainerView.leftAnchor.constraint(equalTo: leftAnchor),
            topContainerView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor),
            topContainerView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}

private extension CGFloat {
    static let titleFontSize: CGFloat = 17
    static let descriptionFontSize: CGFloat = 15
    static let buttonTitleFontSize: CGFloat = 17
    static let interButtonSpace: CGFloat = 8
    static let bottomButtonsOffset: CGFloat = 8
    static let descriptionBottomOffset: CGFloat = 24
    static let titleBottomOffset: CGFloat = 8
    static let bottomContentWidth: CGFloat = 290
    static let imageSide: CGFloat = 220
}
