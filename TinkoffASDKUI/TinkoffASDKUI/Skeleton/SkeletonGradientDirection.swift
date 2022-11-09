//
//  SkeletonGradientDirection.swift
//  popup
//
//  Created by Ivan Glushko on 02.11.2022.
//

import UIKit

enum SkeletonGradientDirection {
    case leftRight
    case rightLeft
    case topBottom
    case bottomTop
    case topLeftBottomRight
    case bottomRightTopLeft
}

extension SkeletonGradientDirection {

    struct AnimationPoint {
        let from: CGPoint
        let to: CGPoint
    }

    var startPoint: AnimationPoint {
        switch self {
        case .leftRight:
            return AnimationPoint(from: CGPoint(x: -1, y: 0.5), to: CGPoint(x: 1, y: 0.5))
        case .rightLeft:
            return AnimationPoint(from: CGPoint(x: 1, y: 0.5), to: CGPoint(x: -1, y: 0.5))
        case .topBottom:
            return AnimationPoint(from: CGPoint(x: 0.5, y: -1), to: CGPoint(x: 0.5, y: 1))
        case .bottomTop:
            return AnimationPoint(from: CGPoint(x: 0.5, y: 1), to: CGPoint(x: 0.5, y: -1))
        case .topLeftBottomRight:
            return AnimationPoint(from: CGPoint(x: -1, y: -1), to: CGPoint(x: 1, y: 1))
        case .bottomRightTopLeft:
            return AnimationPoint(from: CGPoint(x: 1, y: 1), to: CGPoint(x: -1, y: -1))
        }
    }

    var endPoint: AnimationPoint {
        switch self {
        case .leftRight:
            return AnimationPoint(from: CGPoint(x: 0, y: 0.5), to: CGPoint(x: 2, y: 0.5))
        case .rightLeft:
            return AnimationPoint(from: CGPoint(x: 2, y: 0.5), to: CGPoint(x: 0, y: 0.5))
        case .topBottom:
            return AnimationPoint(from: CGPoint(x: 0.5, y: 0), to: CGPoint(x: 0.5, y: 2))
        case .bottomTop:
            return AnimationPoint(from: CGPoint(x: 0.5, y: 2), to: CGPoint(x: 0.5, y: 0))
        case .topLeftBottomRight:
            return AnimationPoint(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 2, y: 2))
        case .bottomRightTopLeft:
            return AnimationPoint(from: CGPoint(x: 2, y: 2), to: CGPoint(x: 0, y: 0))
        }
    }
}
