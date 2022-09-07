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

final class SBPBankCell: UITableViewCell, ReusableCell {
    override var imageView: UIImageView {
        return logoImageView
    }

    var onReuse: (() -> Void)?
    
    let bankTitleLabel = UILabel()
    let logoImageView = UIImageView()
    let tickImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        tickImageView.isHidden = !selected
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tickImageView.isHidden = true
        logoImageView.image = nil
        onReuse?()
    }
}

private extension SBPBankCell {
    func setup() {
        contentView.addSubview(bankTitleLabel)
        contentView.addSubview(logoImageView)
        contentView.addSubview(tickImageView)
        
        selectionStyle = .none
        
        tickImageView.image = Asset.tick24.image
        tickImageView.isHidden = true
        
        bankTitleLabel.numberOfLines = 1
        bankTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        bankTitleLabel.textColor = UIColor.asdk.dynamic.text.primary
        
        setupConstraints()
    }
    
    func setupConstraints() {
        bankTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        tickImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageView.heightAnchor.constraint(equalToConstant: .logoImageSide),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor,
                                                constant: .logoImageLeftOffset),
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                               constant: .logoImageVerticalOffset),
            logoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -.logoImageVerticalOffset),
            
            tickImageView.widthAnchor.constraint(equalToConstant: .tickSide),
            tickImageView.heightAnchor.constraint(equalToConstant: .tickSide),
            tickImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor,
                                                 constant: -.tickRightInset),
            tickImageView.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            
            bankTitleLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            bankTitleLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor,
                                                 constant: .titleLeftInset),
            bankTitleLabel.rightAnchor.constraint(equalTo: tickImageView.leftAnchor,
                                                  constant: -.tickRightInset)
        ])
    }
}

private extension CGFloat {
    static let logoImageSide: CGFloat = 40
    static let logoImageVerticalOffset: CGFloat = 8
    static let logoImageLeftOffset: CGFloat = 16
    static let titleLeftInset: CGFloat = 16
    static let titleRightInset: CGFloat = 16
    static let tickSide: CGFloat = 24
    static let tickRightInset: CGFloat = 16
}
