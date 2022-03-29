//
//
//  PullableContainerView.swift
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

final class PullableContainerView: PassthroughView {
    
    let headerView = PullableContainerHeader()
    let dragView = UIView()
    let containerView = UIView()
    var scrollView: UIScrollView!
    
    private(set) var containerViewHeightConstraint: NSLayoutConstraint!
    private(set) var dragViewHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Content
    
    func addContent(_ content: PullableContainerContent) {
        if let scrollableContent = content as? PullableContainerScrollableContent {
            scrollView = scrollableContent.scrollView
            containerView.addSubview(content.view)
            setupScrollableContentConstraints(content: content)
        } else {
            scrollView = UIScrollView()
            containerView.addSubview(scrollView)
            scrollView.addSubview(content.view)
            setupNonScrollableContentConstraints(content: content)
        }
    }
}

private extension PullableContainerView {
    func setup() {
        addSubview(dragView)
        dragView.addSubview(headerView)
        dragView.addSubview(containerView)
        
        setupHeaderView()
        setupDragView()
        setupConstraints()
    }
    
    func setupHeaderView() {
        headerView.isUserInteractionEnabled = false
    }
    
    func setupDragView() {
        dragView.backgroundColor = UIColor.asdk.dynamic.background.elevation1
        dragView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        dragView.layer.cornerRadius = .cornerRadius
        dragView.layer.masksToBounds = true
    }
    
    func setupConstraints() {
        dragView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        dragViewHeightConstraint = dragView.heightAnchor.constraint(equalToConstant: 0)
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            dragView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dragView.leftAnchor.constraint(equalTo: leftAnchor),
            dragView.rightAnchor.constraint(equalTo: rightAnchor),
            dragViewHeightConstraint,
            
            headerView.topAnchor.constraint(equalTo: dragView.topAnchor),
            headerView.leftAnchor.constraint(equalTo: dragView.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: dragView.rightAnchor),
            headerView.heightAnchor.constraint(equalToConstant: .topViewHeight),
            
            containerView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: dragView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: dragView.rightAnchor),
            containerViewHeightConstraint
        ])
    }
    
    func setupScrollableContentConstraints(content: PullableContainerContent) {
        content.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            content.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            content.view.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            content.view.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            content.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func setupNonScrollableContentConstraints(content: PullableContainerContent) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            content.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.view.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            content.view.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            content.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.view.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            content.view.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
    }
}

private extension CGFloat {
    static let topViewHeight: CGFloat = 24
    static let cornerRadius: CGFloat = 16
}
