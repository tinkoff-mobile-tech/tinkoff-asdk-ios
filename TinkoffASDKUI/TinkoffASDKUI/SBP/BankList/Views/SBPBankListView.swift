//
//
//  SBPBankView.swift
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

final class SBPBankListView: UIView {
    
    // MARK: - Style
    
    struct Style {
        let continueButtonStyle: ButtonStyle
    }
    
    let style: Style
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let headerView = SBPBankListHeaderView()
    let continueButton = BigButton(type: .system)
    let continueButtonContainer = UIView()
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutHeaderView()
    }
}

private extension SBPBankListView {
    func setup() {
        addSubview(tableView)
        addSubview(continueButtonContainer)
        continueButtonContainer.addSubview(continueButton)
        
        tableView.tableHeaderView = headerView
        
        backgroundColor = .white
        continueButtonContainer.backgroundColor = .white
        
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: .buttonFontSize, weight: .regular)
        continueButton.layer.cornerRadius = .buttonCornerRadius
        continueButton.layer.masksToBounds = true
        continueButton.setTitleColor(style.continueButtonStyle.titleColor,
                                     for: .normal)
        continueButton.setTitleColor(UIColor.asdk.darkGray,
                                     for: .disabled)
        continueButton.backgroundColors = [.normal: style.continueButtonStyle.backgroundColor,
                                           .disabled: UIColor.asdk.lightGray,
                                           .highlighted: style.continueButtonStyle.backgroundColor]
        
        setupConstraints()
    }
    
    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let continueButtonBottomConstraint = continueButton.bottomAnchor.constraint(equalTo: continueButtonContainer.bottomAnchor,
                                                                                    constant: -UIEdgeInsets.buttonInsets.bottom)
        continueButtonBottomConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: continueButtonContainer.topAnchor),
            tableView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
            
            headerView.topAnchor.constraint(equalTo: tableView.topAnchor),
            headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            
            continueButton.topAnchor.constraint(equalTo: continueButtonContainer.topAnchor,
                                                constant: UIEdgeInsets.buttonInsets.top),
            continueButton.leftAnchor.constraint(equalTo: continueButtonContainer.leftAnchor,
                                                constant: UIEdgeInsets.buttonInsets.left),
            continueButton.rightAnchor.constraint(equalTo: continueButtonContainer.rightAnchor,
                                                constant: -UIEdgeInsets.buttonInsets.right),
            continueButtonBottomConstraint,
            
            continueButtonContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            continueButtonContainer.leftAnchor.constraint(equalTo: leftAnchor),
            continueButtonContainer.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func layoutHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let tableWidth = tableView.bounds.width
        headerView.bounds.size.width = tableWidth
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let headerViewHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var headerFrame = headerView.frame
        headerFrame.size.height = headerViewHeight
        headerView.frame = headerFrame
        
        tableView.tableHeaderView = headerView
        
        headerView.translatesAutoresizingMaskIntoConstraints = true
      }
}

private extension CGFloat {
    static let buttonHeight: CGFloat = 56
    static let buttonCornerRadius: CGFloat = 16
    static let buttonFontSize: CGFloat = 17
}

private extension UIEdgeInsets {
    static let buttonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 24, right: 16)
}
