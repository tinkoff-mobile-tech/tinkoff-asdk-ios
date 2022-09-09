//
//
//  PullableContainerHeader.swift
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

final class PullableContainerHeader: UIView {
    
    private let notchView = NotchView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        notchView.bounds.size = CGSize(width: 32, height: 5)
        notchView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
}

private extension PullableContainerHeader {
    func setup() {
        backgroundColor = UIColor.asdk.dynamic.background.elevation1
        addSubview(notchView)
    }
}
