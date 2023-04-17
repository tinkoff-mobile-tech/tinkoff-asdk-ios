//
//  SBPQrViewController.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 14.03.2023.
//

import UIKit

final class SBPQrViewController: UIViewController, ISBPQrViewInput {
    // MARK: Internal Types

    private enum PresentationState {
        case commonSheet
        case tableView
    }

    // MARK: Dependencies

    weak var pullableContentDelegate: PullableContainerСontentDelegate?
    private let presenter: ISBPQrViewOutput

    // MARK: Properties

    private lazy var tableView = UITableView(frame: view.bounds)
    private lazy var commonSheetView = CommonSheetView(delegate: self)

    // MARK: State

    private var tableViewContentSizeObservation: NSKeyValueObservation?
    private var presentationState: PresentationState = .commonSheet

    // MARK: Initialization

    init(presenter: ISBPQrViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "init with coder is unavailable.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewsHierarchy()
        setupTableView()
        setupTableContentSizeObservation()
        presenter.viewDidLoad()
    }
}

// MARK: - ISBPQrViewInput

extension SBPQrViewController {
    func showCommonSheet(state: CommonSheetState, animatePullableContainerUpdates: Bool) {
        presentationState = .commonSheet

        commonSheetView.showOverlay {
            self.commonSheetView.set(state: state)

            self.pullableContentDelegate?.updateHeight(
                animated: animatePullableContainerUpdates,
                alongsideAnimation: { self.commonSheetView.hideOverlay(animated: !animatePullableContainerUpdates) }
            )
        }
    }

    func hideCommonSheet() {
        presentationState = .tableView

        commonSheetView.showOverlay {
            self.commonSheetView.set(state: .clear)

            self.pullableContentDelegate?.updateHeight(
                animated: true,
                alongsideAnimation: { self.commonSheetView.hideOverlay(animated: false) }
            )
        }
    }

    func reloadData() {
        tableView.reloadData()
    }

    func closeView() {
        dismiss(animated: true, completion: presenter.viewWasClosed)
    }
}

// MARK: - UITableViewDataSource

extension SBPQrViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = presenter.cellType(at: indexPath)

        switch cellType {
        case let .textHeader(presenter):
            let cell = tableView.dequeue(cellType: TextAndImageHeaderTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .textHeaderInsets
            return cell
        case let .qrImage(presenter):
            let cell = tableView.dequeue(cellType: QrImageTableCell.self, indexPath: indexPath)
            cell.containedView.presenter = presenter
            cell.insets = .qrImageInsets
            return cell
        }
    }
}

// MARK: - PullableContainerContent Methods

extension SBPQrViewController: PullableContainerContent {
    func pullableContainer(
        _ contentDelegate: PullableContainerСontentDelegate,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat {
        switch presentationState {
        case .commonSheet:
            return commonSheetView.estimatedHeight
        case .tableView:
            return tableView.contentSize.height
        }
    }

    func pullableContainerWasClosed(_ contentDelegate: PullableContainerСontentDelegate) {
        presenter.viewWasClosed()
    }
}

// MARK: - CommonSheetViewDelegate

extension SBPQrViewController: CommonSheetViewDelegate {
    func commonSheetView(_ commonSheetView: CommonSheetView, didUpdateWithState state: CommonSheetState) {}

    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView) {
        presenter.commonSheetViewDidTapPrimaryButton()
    }

    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView) {
        presenter.commonSheetViewDidTapSecondaryButton()
    }
}

// MARK: - Private

extension SBPQrViewController {
    private func setupViewsHierarchy() {
        view.addSubview(tableView)
        tableView.pinEdgesToSuperview()

        view.addSubview(commonSheetView)
        commonSheetView.pinEdgesToSuperview()
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.delaysContentTouches = false
        tableView.dataSource = self

        tableView.register(TextAndImageHeaderTableCell.self, QrImageTableCell.self)
    }

    private func setupTableContentSizeObservation() {
        tableViewContentSizeObservation = tableView.observe(\.contentSize, options: [.new, .old]) { [weak self] _, change in
            guard let self = self,
                  change.oldValue != change.newValue,
                  self.presentationState == .tableView else { return }

            self.pullableContentDelegate?.updateHeight()
        }
    }
}

// MARK: - Constants

private extension UIEdgeInsets {
    static let textHeaderInsets = UIEdgeInsets(vertical: 10, horizontal: 16)
    static let qrImageInsets = UIEdgeInsets(vertical: 10, horizontal: 16)
}
