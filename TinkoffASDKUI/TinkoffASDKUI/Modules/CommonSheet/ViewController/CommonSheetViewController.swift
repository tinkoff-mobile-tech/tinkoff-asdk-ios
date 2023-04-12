//
//  CommonSheetViewController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 12.12.2022.
//

import UIKit

final class CommonSheetViewController: UIViewController, PullableContainerContent {
    // MARK: Dependencies

    weak var pullableContainer: PullableContainerСontentDelegate?
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
    func update(state: CommonSheetState) {
        commonSheetView.update(state: state)
    }

    func close() {
        dismiss(animated: true, completion: presenter.viewWasClosed)
    }
}

// MARK: - CommonSheetViewDelegate

extension CommonSheetViewController: CommonSheetViewDelegate {
    func commonSheetView(_ commonSheetView: CommonSheetView, didUpdateWithState state: CommonSheetState) {
        pullableContainer?.updateHeight(animated: true)
    }

    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView) {
        presenter.primaryButtonTapped()
    }

    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView) {
        presenter.secondaryButtonTapped()
    }
}

// MARK: - PullableContainerContent

extension CommonSheetViewController {
    func pullableContainerDidRequestCurrentAnchorIndex(_ pullableContainer: PullableContainerСontentDelegate) -> Int {
        .zero
    }

    func pullableContainer(_ pullableContainer: PullableContainerСontentDelegate, didChange currentAnchorIndex: Int) {}

    func pullableContainerWasClosed() {
        presenter.viewWasClosed()
    }

    func pullableContainerShouldDismissOnDownDragging() -> Bool {
        presenter.canDismissViewByUserInteraction()
    }

    func pullableContainerShouldDismissOnDimmingViewTap() -> Bool {
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
