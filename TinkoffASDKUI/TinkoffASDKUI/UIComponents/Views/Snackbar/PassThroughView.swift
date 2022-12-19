//
//  PassThroughView.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 13.12.2022.
//

import Foundation

/// Propagates touch events down the view hierarchy
class PassThroughView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
