//
//  CommonSheetViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import UIKit

final class CommonSheetViewController: UIViewController, IPullableContainerContent {
    // MARK: Dependencies

    weak var pullableContentDelegate: PullableContainerСontentDelegate?
    private let presenter: ICommonSheetPresenter

    // MARK: UI

    private lazy var commonSheetView = CommonSheetView(delegate: self)

    // MARK: Init

    init(presenter: ICommonSheetPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Cycle

    override func loadView() {
        view = commonSheetView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

// MARK: - ICommonSheetView

extension CommonSheetViewController: ICommonSheetView {
    func update(state: CommonSheetState, animatePullableContainerUpdates: Bool) {
        commonSheetView.showOverlay(animated: true) {
            self.pullableContentDelegate?.updateHeight(
                animated: animatePullableContainerUpdates,
                alongsideAnimation: {
                    self.commonSheetView.hideOverlay(animated: !animatePullableContainerUpdates)
                }
            )
        }
    }

    func close() {
        dismiss(animated: true, completion: presenter.viewWasClosed)
    }
}

// MARK: - CommonSheetViewDelegate

extension CommonSheetViewController: CommonSheetViewDelegate {
    func commonSheetView(_ commonSheetView: CommonSheetView, didUpdateWithState state: CommonSheetState) {
        pullableContentDelegate?.updateHeight()
    }

    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView) {
        presenter.primaryButtonTapped()
    }

    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView) {
        presenter.secondaryButtonTapped()
    }
}

// MARK: - IPullableContainerContent

extension CommonSheetViewController {
    func pullableContainerWasClosed(_ contentDelegate: PullableContainerСontentDelegate) {
        presenter.viewWasClosed()
    }

    func pullableContainerShouldDismissOnDownDragging(_ contentDelegate: PullableContainerСontentDelegate) -> Bool {
        presenter.canDismissViewByUserInteraction()
    }

    func pullableContainerShouldDismissOnDimmingViewTap(_ contentDelegate: PullableContainerСontentDelegate) -> Bool {
        presenter.canDismissViewByUserInteraction()
    }

    func pullableContainer(
        _ container: PullableContainerСontentDelegate,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat {
        commonSheetView.estimatedHeight
    }
}
