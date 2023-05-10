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

    weak var pullableContentDelegate: IPullableContainerСontentDelegate?
    private let presenter: ISBPQrViewOutput
    private let tableContentProvider: any ISBPQrTableContentProvider

    // MARK: Properties

    private lazy var tableView = UITableView(frame: view.bounds)
    private lazy var commonSheetView = CommonSheetView(delegate: self)

    // MARK: State

    private var presentationState: PresentationState = .commonSheet

    // MARK: Initialization

    init(presenter: ISBPQrViewOutput, tableContentProvider: any ISBPQrTableContentProvider) {
        self.presenter = presenter
        self.tableContentProvider = tableContentProvider
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
        tableContentProvider.dequeueCell(
            from: tableView,
            at: indexPath,
            withType: presenter.cellType(at: indexPath)
        )
    }
}

// MARK: - UITableViewDelegate

extension SBPQrViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableContentProvider.height(for: presenter.cellType(at: indexPath), in: tableView)
    }
}

// MARK: - IPullableContainerContent

extension SBPQrViewController: IPullableContainerContent {
    func pullableContainer(
        _ contentDelegate: IPullableContainerСontentDelegate,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat {
        switch presentationState {
        case .commonSheet:
            return commonSheetView.estimatedHeight
        case .tableView:
            return tableContentProvider.pullableContainerHeight(
                for: presenter.allCells(),
                in: tableView,
                availableSpace: availableSpace
            )
        }
    }

    func pullableContainerWasClosed(_ contentDelegate: IPullableContainerСontentDelegate) {
        presenter.viewWasClosed()
    }
}

// MARK: - ICommonSheetViewDelegate

extension SBPQrViewController: ICommonSheetViewDelegate {
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
        tableView.delegate = self

        tableContentProvider.registerCells(in: tableView)
    }
}

// MARK: - ISBPQrViewOutput + Helpers

private extension ISBPQrViewOutput {
    func allCells() -> [SBPQrCellType] {
        (0 ..< numberOfRows()).map { cellType(at: IndexPath(row: $0, section: .zero)) }
    }
}
