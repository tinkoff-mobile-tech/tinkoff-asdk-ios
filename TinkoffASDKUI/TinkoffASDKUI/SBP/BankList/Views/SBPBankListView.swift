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
    let tableView = UITableView(frame: .zero, style: .plain)
    let headerView = SBPBankListHeaderView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        tableView.tableHeaderView = headerView
        
        backgroundColor = .white
        
        setupConstraints()
    }
    
    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            
            headerView.topAnchor.constraint(equalTo: tableView.topAnchor),
            headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
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
