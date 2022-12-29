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
        let cardCellHeight = Constants.cardCellHeight
        let numberOfCards = 5

        // cards

        for cardNumber in 0 ..< numberOfCards {
            let yInset = Constants.topInset + (CGFloat(cardNumber) * cardCellHeight)
            let (cardIconSkeleton, cardNumberSkeleton) = assembleCardSkeletonViews(yInset: yInset)
            [cardIconSkeleton, cardNumberSkeleton].forEach { skeletonContainer.addSubview($0) }
            skeletonCards.append((icon: cardIconSkeleton, number: cardNumberSkeleton))
        }

        // add card
        let yInset = Constants.topInset + (cardCellHeight * CGFloat(numberOfCards))
        let (cardIconSkeleton, cardNumberSkeleton) = assembleCardSkeletonViews(yInset: yInset)
        [cardIconSkeleton, cardNumberSkeleton].forEach { skeletonContainer.addSubview($0) }
        skeletonCards.append((icon: cardIconSkeleton, number: cardNumberSkeleton))
        cardIconSkeleton.configure(
            model: SkeletonView.Model(color: ASDKColors.Foreground.skeleton, cornerRadius: Constants.bigCornerRadius)
        )
        cardIconSkeleton.frame = Constants.calculateCardIconSkeletonFrameForAddCard(yInset: yInset)
        startSkeletonWaterfallAnimation(cards: skeletonCards)
        return skeletonContainer
    }

    private func assembleCardSkeletonViews(yInset: CGFloat) -> (
        cardIconSkeleton: SkeletonView,
        cardNumberSkeleton: SkeletonView
    ) {
        let cardIconSkeletonView = SkeletonView()
        let cardNumberSkeletonView = SkeletonView()
        let skeletonModel = SkeletonView.Model(color: ASDKColors.Foreground.skeleton, cornerRadius: Constants.smallCornerRadius)
        [cardIconSkeletonView, cardNumberSkeletonView].configure(model: skeletonModel)
        cardIconSkeletonView.frame = Constants.calculateCardIconSkeletonFrame(yInset: yInset)
        cardNumberSkeletonView.frame = Constants.calculateCardNumberSkeletonFrame(yInset: yInset)
        return (cardIconSkeletonView, cardNumberSkeletonView)
    }

    private func startSkeletonWaterfallAnimation(cards: [CardCell]) {
        cards.enumerated().forEach { index, tuple in
            [tuple.icon, tuple.number].forEach { skeleton in
                skeleton.startAnimating(
                    animationType: .waterfall(index: CGFloat(index), delay: Constants.waterfallDelat)
                )
            }
        }
    }
}

private extension CardListView {

    struct Constants {
        static let topInset: CGFloat = 15
        static let smallCornerRadius: CGFloat = 4
        static let bigCornerRadius: CGFloat = 20
        static let waterfallDelat: Double = 0.2
        static let cardIconSkeletonFrame = CGRect(x: 16, y: 15, width: 40, height: 26)
        static let cardCellHeight: CGFloat = 56

        static func calculateCardIconSkeletonFrame(yInset: CGFloat) -> CGRect {
            CGRect(x: 16, y: 15 + yInset, width: 40, height: 26)
        }

        static func calculateCardNumberSkeletonFrame(yInset: CGFloat) -> CGRect {
            CGRect(x: 72, y: 20 + yInset, width: 140, height: 14)
        }

        static func calculateCardIconSkeletonFrameForAddCard(yInset: CGFloat) -> CGRect {
            CGRect(x: 16, y: 8 + yInset, width: 40, height: 40)
        }
    }
}
