//
//
//  LoadingViewController.swift
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

final class LoadingViewController: UIViewController, PullableContainerContent {
    var contentHeight: CGFloat {
        return 100
    }
    
    var contentHeightDidChange: ((PullableContainerContent) -> Void)?
    
    private let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        startActivity()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentHeightDidChange?(self)
    }
    
    func startActivity() {
        activityIndicator.startAnimating()
    }
    
    func stopActivity() {
        activityIndicator.stopAnimating()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateActivityIndicatorStyle()
    }
}

private extension LoadingViewController {
    func setup() {
        view.backgroundColor = UIColor.asdk.dynamic.background.elevation1
        view.addSubview(activityIndicator)
        
        activityIndicator.style = .gray
        setupContraints()
    }
    
    func setupContraints() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
        ])
    }
    
    func updateActivityIndicatorStyle() {
        if #available(iOS 13.0, *) {
            switch UITraitCollection.current.userInterfaceStyle {
            case .dark:
                activityIndicator.style = .white
            case .light:
                activityIndicator.style = .gray
            default:
                activityIndicator.style = .white
            }
        }
    }
}
