//
//
//  ContainerTableViewCell.swift
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

final class ContainerTableViewCell: UITableViewCell, ReusableCell {
    var onReuse: (() -> Void)?
    
    private let containerView = UIView()
    private var cellContentView: UIView?
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        cellContentView?.removeFromSuperview()
        cellContentView = nil
        onReuse?()
    }
    
    func setContent(_ contentView: UIView,
                    insets: UIEdgeInsets) {
        cellContentView?.removeFromSuperview()
        cellContentView = nil
        
        cellContentView = contentView
        containerView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: insets.top),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -insets.bottom),
            contentView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: insets.left),
            contentView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -insets.right)
        ])
    }
}

private extension ContainerTableViewCell {
    func setup() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
