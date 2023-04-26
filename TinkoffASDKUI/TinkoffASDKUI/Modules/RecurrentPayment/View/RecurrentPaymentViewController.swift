//
//  RecurrentPaymentViewController.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

import UIKit
import WebKit

final class RecurrentPaymentViewController: UIViewController, IRecurrentPaymentViewInput {
    // MARK: Internal Types

    private enum Anchor: CaseIterable {
        case contentBased
        case expanded
    }

    private enum PresentationState {
        case commonSheet
        case tableView
    }

    // MARK: Dependencies

    weak var pullableContentDelegate: PullableContainerСontentDelegate?
    private let presenter: IRecurrentPaymentViewOutput
    private let tableContentProvider: IRecurrentPaymentTableContentProvider
    private let keyboardService = KeyboardService()

    // MARK: Properties

    private lazy var tableView = UITableView(frame: view.bounds)
    private lazy var commonSheetView = CommonSheetView(delegate: self)
    private lazy var webView = WKWebView()

    // MARK: State

    private let anchors = Anchor.allCases
    private var currentAnchor: Anchor = .contentBased
    private var presentationState: PresentationState = .commonSheet

    // MARK: Initialization

    init(presenter: IRecurrentPaymentViewOutput, tableContentProvider: IRecurrentPaymentTableContentProvider) {
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
        setupWebView()
        setupTableView()
        setupKeyboardObserving()
        presenter.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter.viewDidAppear()
    }
}

// MARK: - IRecurrentPaymentViewInput

extension RecurrentPaymentViewController {
    func showCommonSheet(state: CommonSheetState, animatePullableContainerUpdates: Bool) {
        presentationState = .commonSheet
        currentAnchor = .contentBased

        commonSheetView.showOverlay(animated: true) {
            self.commonSheetView.set(state: state)

            self.pullableContentDelegate?.updateHeight(
                animated: animatePullableContainerUpdates,
                alongsideAnimation: { self.commonSheetView.hideOverlay(animated: !animatePullableContainerUpdates) }
            )
        }
    }

    func hideCommonSheet() {
        presentationState = .tableView
        currentAnchor = .contentBased
        tableView.setContentOffset(.zero, animated: false)

        commonSheetView.showOverlay(animated: true) {
            self.commonSheetView.set(state: .clear)

            self.pullableContentDelegate?.updateHeight(
                animated: true,
                alongsideAnimation: { self.commonSheetView.hideOverlay(animated: false) }
            )
        }
    }

    func hideKeyboard() {
        view.endEditing(true)
    }

    func reloadData() {
        tableView.reloadData()
    }

    func closeView() {
        dismiss(animated: true, completion: presenter.viewWasClosed)
    }
}

// MARK: - UITableViewDataSource

extension RecurrentPaymentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableContentProvider.dequeueCell(from: tableView, at: indexPath, withType: presenter.cellType(at: indexPath))
    }
}

// MARK: - UITableViewDelegate

extension RecurrentPaymentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableContentProvider.height(for: presenter.cellType(at: indexPath), in: tableView)
    }
}

// MARK: - IPullableContainerContent Methods

extension RecurrentPaymentViewController: IPullableContainerContent {
    func pullableContainerDidRequestCurrentAnchorIndex(_ contentDelegate: PullableContainerСontentDelegate) -> Int {
        anchors.firstIndex(of: currentAnchor) ?? .zero
    }

    func pullableContainer(_ contentDelegate: PullableContainerСontentDelegate, didChange currentAnchorIndex: Int) {
        currentAnchor = anchors[currentAnchorIndex]
    }

    func pullableContainer(
        _ contentDelegate: PullableContainerСontentDelegate,
        didRequestHeightForAnchorAt index: Int,
        availableSpace: CGFloat
    ) -> CGFloat {
        switch (anchors[index], presentationState) {
        case (.contentBased, .tableView):
            return tableContentProvider.pullableContainerHeight(
                for: presenter.allCells(),
                in: tableView,
                availableSpace: availableSpace
            )
        case (.contentBased, .commonSheet):
            return commonSheetView.estimatedHeight
        case (.expanded, _):
            return availableSpace
        }
    }

    func pullableContainer(_ contentDelegate: PullableContainerСontentDelegate, didDragWithOffset offset: CGFloat) {
        hideKeyboard()
    }

    func pullableContainerWasClosed(_ contentDelegate: PullableContainerСontentDelegate) {
        presenter.viewWasClosed()
    }
}

// MARK: - CommonSheetViewDelegate

extension RecurrentPaymentViewController: CommonSheetViewDelegate {
    func commonSheetViewDidTapPrimaryButton(_ commonSheetView: CommonSheetView) {
        presenter.commonSheetViewDidTapPrimaryButton()
    }

    func commonSheetViewDidTapSecondaryButton(_ commonSheetView: CommonSheetView) {}
}

// MARK: - ThreeDSWebFlowDelegate

extension RecurrentPaymentViewController: ThreeDSWebFlowDelegate {
    func hiddenWebViewToCollect3DSData() -> WKWebView { webView }
    func sourceViewControllerToPresent() -> UIViewController? { self }
}

// MARK: - Private

extension RecurrentPaymentViewController {
    private func setupViewsHierarchy() {
        view.addSubview(webView)
        webView.pinEdgesToSuperview()

        view.addSubview(tableView)
        tableView.pinEdgesToSuperview()

        view.addSubview(commonSheetView)
        commonSheetView.pinEdgesToSuperview()
    }

    private func setupWebView() {
        webView.isHidden = true
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.delaysContentTouches = false
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self

        tableContentProvider.registerCells(in: tableView)
    }

    private func setupKeyboardObserving() {
        keyboardService.onHeightDidChangeBlock = { [weak self] _, _ in
            guard let self = self, self.currentAnchor != .expanded else { return }
            self.currentAnchor = .expanded
            self.pullableContentDelegate?.updateHeight()
        }
    }
}

// MARK: - IRecurrentPaymentViewOutput + Helpers

private extension IRecurrentPaymentViewOutput {
    func allCells() -> [RecurrentPaymentCellType] {
        (0 ..< numberOfRows()).map { cellType(at: IndexPath(row: $0, section: .zero)) }
    }
}
