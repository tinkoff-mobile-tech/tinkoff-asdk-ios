//
//  CardListView+Shimmer.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 12.12.2022.
//

import UIKit

private typealias CardCell = (icon: SkeletonView, number: SkeletonView)

extension CardListView {

    func buildShimmerView() -> UIView {
        let skeletonContainer = UIView()
        var skeletonCards: [CardCell] = []

        let cardCellHeight = 56 as CGFloat

        // cards

        for cardNumber in 0 ..< 5 {
            let yInset = (CGFloat(cardNumber) * cardCellHeight)
            let (cardIconSkeleton, cardNumberSkeleton) = assembleCardSkeletonViews(yInset: yInset)
            [cardIconSkeleton, cardNumberSkeleton].forEach { skeletonContainer.addSubview($0) }
            skeletonCards.append((icon: cardIconSkeleton, number: cardNumberSkeleton))
        }

        // add card

        let (cardIconSkeleton, cardNumberSkeleton) = assembleCardSkeletonViews(yInset: cardCellHeight * 5)
        [cardIconSkeleton, cardNumberSkeleton].forEach { skeletonContainer.addSubview($0) }
        skeletonCards.append((icon: cardIconSkeleton, number: cardNumberSkeleton))
        cardIconSkeleton.configure(
            model: SkeletonView.Model(color: ASDKColors.Foreground.skeleton, cornerRadius: 20)
        )
        cardIconSkeleton.frame = CGRect(x: 16, y: 8 + cardCellHeight * 5, width: 40, height: 40)
        startSkeletonWaterfallAnimation(cards: skeletonCards)
        return skeletonContainer
    }

    private func assembleCardSkeletonViews(yInset: CGFloat) -> (
        cardIconSkeleton: SkeletonView,
        cardNumberSkeleton: SkeletonView
    ) {
        let cardIconSkeletonView = SkeletonView()
        let cardNumberSkeletonView = SkeletonView()
        let skeletonModel = SkeletonView.Model(color: ASDKColors.Foreground.skeleton, cornerRadius: 4)
        [cardIconSkeletonView, cardNumberSkeletonView].configure(model: skeletonModel)
        cardIconSkeletonView.frame = CGRect(x: 16, y: 15 + yInset, width: 40, height: 26)
        cardNumberSkeletonView.frame = CGRect(x: 72, y: 20 + yInset, width: 140, height: 14)
        return (cardIconSkeletonView, cardNumberSkeletonView)
    }

    private func startSkeletonWaterfallAnimation(cards: [CardCell]) {
        cards.enumerated().forEach { index, tuple in
            [tuple.icon, tuple.number].forEach { skeleton in
                skeleton.startAnimating(
                    animationType: .waterfall(index: CGFloat(index), delay: 0.2)
                )
            }
        }
    }
}
