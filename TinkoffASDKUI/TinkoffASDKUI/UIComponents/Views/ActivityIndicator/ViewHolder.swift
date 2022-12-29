//
//  ViewContainer.swift
//  popup
//
//  Created by Ivan Glushko on 14.11.2022.
//

import UIKit

final class ViewHolder<T: UIView>: UIView {
    var base: T

    init(base: T) {
        self.base = base
        super.init(frame: .zero)

        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Has not been implemented!!!")
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(base)

        base.makeConstraints { make in
            [
                make.centerXAnchor.constraint(equalTo: make.forcedSuperview.centerXAnchor),
                make.centerYAnchor.constraint(equalTo: make.forcedSuperview.centerYAnchor),
            ]
        }
    }
}
